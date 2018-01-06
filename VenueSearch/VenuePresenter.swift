import Foundation
import CoreLocation

struct VenueViewData {
    let name: String
    let address: String
    let distance: Int
    let rating: Double
}

protocol VenueView: NSObjectProtocol {
    var isVenueSelectorEnabled: Bool {get set}
    func startLoading()
    func finishLoading()
    func setVenues(_ empty: Bool)
    func showErrorAlert(_ title: String, _ message: String, _ errorType: VenueError)
}

class VenuePresenter: NSObject {
    private let venueService: VenueService!
    private let locationService: CLLocationManager!
    private let venueCatelog = ["food", "drinks", "coffee", "shops", "arts", "outdoors", "sights", "trending", "topPicks"]
    private var venuesToDisplay = [VenueViewData]()
    private var currentLocation: CLLocation?
    weak private var venueView : VenueView?
    
    init(venueService: VenueService, locationService: CLLocationManager) {
        self.venueService = venueService
        self.locationService = locationService
    }
    
    func venueCatelogToShow() -> [String] {
        return venueCatelog
    }
    
    func attachView(_ view: VenueView) {
        venueView = view
        locationService.delegate = self
    }
    
    func detachView() {
        venueView = nil
    }
    
    func viewWillAppear() {
        requestLocationPermission()
        if (isLocationEnabled()) {
            getCurrentLocation()
        }
    }
    
    func showSelectedVenue(venue: String) {
        if (!isLocationEnabled()) {
            venueView?.showErrorAlert("Location Disabled", "Please enable location", .locationAuthenticationFailed)
            return;
        }
        
        guard let location = currentLocation else {
            getCurrentLocation()
            venueView?.showErrorAlert("Getting Location", "Please wait", .locationRequestPending)
            return
        }
        
        guard URL(string: venue) != nil else {
            venueView?.showErrorAlert("venue error", "venue catelog is invalid", .requestFailed)
            return
        }
        
        getVenues(venue: venue, longitude: location.coordinate.longitude, latitude: location.coordinate.latitude)
    }
    
    // MARK: talbeView delegate
    func numberOfVenues() -> Int {
        return venuesToDisplay.count
    }
    
    func configureCell(forRow row: Int, cell: SearchCell) {
        let venueViewData = venuesToDisplay[row]
        cell.title.text = venueViewData.name
        cell.rating.text = String(venueViewData.rating) + "⭐️"
        cell.distance.text = String(venueViewData.distance) + "m"
        cell.address.text = venueViewData.address
    }
    
    // MARK: helper
    private func getVenues(venue: String, longitude: Double, latitude: Double) {
        self.venueView?.startLoading()
        
        venueService.getVenues(venue, longtitute: longitude, latitute: latitude, { [weak self] result in
            self?.venueView?.finishLoading()
            switch result {
            case .success(let venues):
            
                if venues.results.count == 0 {
                    self?.venueView?.setVenues(true)
                } else {
                    self?.venuesToDisplay = venues.results.map {
                        return VenueViewData(name: $0.name,
                                             address: $0.address,
                                             distance: $0.distance,
                                             rating: $0.rating)
                    }
                    self?.venueView?.setVenues(false)
                }
                
            case .failure(let error):
                self?.venueView?.showErrorAlert("venue service error", error.localizedDescription, error)
            }
        })
    }
    
    private func isLocationEnabled() -> Bool {
        if type(of: locationService).locationServicesEnabled() {
            switch(type(of: locationService).authorizationStatus()) {
            case .authorizedWhenInUse:
                return true
            default:
                return false
            }
        } else {
            return false
        }
    }
    
    private func requestLocationPermission() {
        locationService.requestWhenInUseAuthorization()
    }
    
    private func getCurrentLocation() {
        locationService.requestLocation()
    }
}

extension VenuePresenter: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        if (!(venueView?.isVenueSelectorEnabled)!) {
            venueView?.isVenueSelectorEnabled = true;
            getVenues(venue: venueCatelog[0],
                      longitude: currentLocation!.coordinate.longitude,
                      latitude: currentLocation!.coordinate.latitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        venueView?.showErrorAlert("Location error", error.localizedDescription, .locationError)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status.hashValue)
        if (status == CLAuthorizationStatus.authorizedAlways ||
            status == CLAuthorizationStatus.authorizedWhenInUse) && currentLocation == nil {
            getCurrentLocation()
        }
    }
}
