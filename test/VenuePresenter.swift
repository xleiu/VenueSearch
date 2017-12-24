import Foundation
import CoreLocation

struct VenueViewData
{
    let name: String
    let address: String
    let distance: Int
    let rating: Double
}

protocol VenueView: NSObjectProtocol {
    func startLoading()
    func finishLoading()
    func setVenues(_ venues: [VenueViewData])
    func setEmptyVenues()
    func attachLocatoinDelegate(_ locationService: CLLocationManager)
}

class VenuePresenter {
    private let venueService: VenueService!
    private let locationService: CLLocationManager!
    weak private var venueView : VenueView?
    
    init(venueService: VenueService, locationService: CLLocationManager) {
        self.venueService = venueService
        self.locationService = locationService
    }
    
    func attachView(_ view: VenueView) {
        venueView = view
        view.attachLocatoinDelegate(locationService)
    }
    
    func detachView() {
        venueView = nil
    }
    
    func isLocationEnabled() -> Bool {
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
    
    func requestLocationPermission() {
        locationService.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() {
        locationService.requestLocation()
    }
    
    func getVenues(venue: String, longitude: Double, latitude: Double) {
        self.venueView?.startLoading()
        
        venueService.getVenues(vanue: venue, longtitute: longitude, latitute: latitude, { [weak self] venues in
            self?.venueView?.finishLoading()
            if venues.count == 0 {
                self?.venueView?.setEmptyVenues()
            } else {
                let mappedVenues = venues.map { (value: Venue) in
                    return VenueViewData(name: value.name, address: value.address, distance: value.distance, rating: value.rating)
                }
                self?.venueView?.setVenues(mappedVenues)
            }
        })
    }
}
