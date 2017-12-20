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
    func setLocation(_ location: CLLocation)
}

class VenuePresenter {
    fileprivate let venueService: FourSquareService
    fileprivate let locationService: LocationService
    weak fileprivate var venueView : VenueView?
    
    init(venueService: FourSquareService, locationService: LocationService) {
        self.venueService = venueService
        self.locationService = locationService
    }
    
    func attachView(_ view: VenueView){
        venueView = view
    }
    
    func detachView() {
        venueView = nil
    }
    
    func isLocationEnabled() ->Bool {
        if type(of: locationService).locationServicesEnabled() {
            switch(type(of: locationService).authorizationStatus()) {
            case .authorizedWhenInUse:
                locationService.requestLocation()
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
        let location = locationService.location
        venueView?.setLocation(location!)
    }
    
    func getVenues(venue: String, loc: CLLocation) {
        self.venueView?.startLoading()
        
        venueService.getVenues(vanue: venue, longtitute: loc.coordinate.longitude, latitute: loc.coordinate.latitude, { [weak self] venues in
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
