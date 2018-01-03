import Foundation
import CoreLocation

class MockLocationManager: CLLocationManager {
    
    override func requestWhenInUseAuthorization() -> Void {
    }
    
    override class func locationServicesEnabled() -> Bool {
        return true;
    }
    
    override class func authorizationStatus() -> CLAuthorizationStatus {
        return .authorizedWhenInUse
    }
    
    override func requestLocation() {
        delegate?.locationManager?(self, didUpdateLocations: [CLLocation(latitude: 60.2365327, longitude: 24.782747)])
    }
}

