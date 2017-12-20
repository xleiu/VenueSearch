import Foundation
import CoreLocation

protocol LocationService {
    var location: CLLocation? { get }
    var desiredAccuracy: CLLocationAccuracy { get set }
    static func locationServicesEnabled() -> Bool
    func requestWhenInUseAuthorization() -> Void
    func requestLocation()
    static func authorizationStatus() -> CLAuthorizationStatus
}

extension CLLocationManager: LocationService {
    
}

protocol MockLocationDelegate: class {
    func mockLocationManager(_ manager: MockLocationManager, didUpdateLocation locations: [CLLocation])
}

class MockLocationManager: LocationService {
    weak private var delegate: MockLocationDelegate?
    
    var location: CLLocation? = CLLocation(latitude: 60.2365327, longitude: 24.782747)
    private var _accuracy: CLLocationAccuracy = kCLLocationAccuracyNearestTenMeters
    var desiredAccuracy: CLLocationAccuracy  { get {return _accuracy} set {_accuracy = newValue} }
    func requestWhenInUseAuthorization() -> Void {
    }
    
    func requestLocation() {
        if delegate == nil {
            print("delegate is nil")
        }
        self.delegate?.mockLocationManager(self, didUpdateLocation: [CLLocation(latitude: 60.2365327, longitude: 24.782747)])
    }
    
    class func locationServicesEnabled() -> Bool {
        return true;
    }
    
    class func authorizationStatus() -> CLAuthorizationStatus
    {
        return .authorizedWhenInUse
    }
}

