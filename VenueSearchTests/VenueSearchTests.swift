import XCTest
import CoreLocation

@testable import VenueSearch

class VenueServiceMock: VenueService {
    private let venues: [Venue]
    private var error = ""
    var errorType = VenueErrorType.None
    
    init(venues: [Venue]) {
        self.venues = venues
    }
    
    func getVenues(vanue: String, longtitute: Double, latitute: Double,
                   _ callBack: @escaping ([Venue], String, VenueErrorType)-> Void) {
        callBack(self.venues, error, errorType)
    }
    
}

class VenueViewMock : NSObject, VenueView {
    var setVenuesCalled = false
    var setEmptyVenuesCalled = false
    var startLoadingCalled = false
    var finishLoadingCalled = false
    var locationNotAvailableCalled = false
    var locationDisableCalled = false
    var networkErrorCalled = false
    var isVenueSelectorEnabled: Bool
    
    override init() {
        isVenueSelectorEnabled = true
    }
    
    func setVenues(_ empty: Bool) {
        if empty {
            setVenuesCalled = true
        } else {
            setEmptyVenuesCalled = true
        }
    }
    
    func showErrorAlert(_ title: String, _ message: String, _ errorType: VenueErrorType){
        switch errorType {
        case .LocationAuthentication:
            locationDisableCalled = true
            
        case .WaitForLocation:
            locationNotAvailableCalled = true
            
        case .Network:
            networkErrorCalled = true
            
        default:
            print(errorType)
        }
    }
    
    func attachLocatoinDelegate(_ locationService: CLLocationManager) {
        
    }
    
    func startLoading() {
        startLoadingCalled = true
    }
    
    func finishLoading() {
        finishLoadingCalled = true
    }
}

class MockLCManager: CLLocationManager {
    var requestLocationCalled = false
    var requestWheInUseAuthorizationCalled = false

    override func requestWhenInUseAuthorization() -> Void {
        requestWheInUseAuthorizationCalled = true
    }
    
    override class func locationServicesEnabled() -> Bool {
        return true
    }
    
    override class func authorizationStatus() -> CLAuthorizationStatus {
        return .authorizedWhenInUse
    }
    
    override func requestLocation() {
        requestLocationCalled = true
    }
}

class MockLCManagerDisableLocation: MockLCManager {
    
    override class func locationServicesEnabled() -> Bool {
        return false;
    }
}


class VenuePresenterTest: XCTestCase {
    
    let emptyVenuesServiceMock = VenueServiceMock(venues: [Venue]())
    
    let twoVenuesServiceMock = VenueServiceMock(venues: [Venue(name: "name1", address: "address1", distance: 300, rating: 8),
                                                     Venue(name: "name2", address: "address2", distance: 200, rating: 5)])
    
    func testShouldSetVenues() {
        //given
        let venueViewMock = VenueViewMock()
        let sut = VenuePresenter(venueService: twoVenuesServiceMock, locationService: MockLCManager())
        sut.attachView(venueViewMock)
        
        //when
        sut.getVenues(venue:  "", longitude: 12, latitude: 13)
        
        //verify
        XCTAssertTrue(venueViewMock.setVenuesCalled)
        XCTAssert(venueViewMock.finishLoadingCalled)
    }
    
    func testShouldClearVenues() {
        let venueViewMock = VenueViewMock()
        let sut = VenuePresenter(venueService: emptyVenuesServiceMock, locationService: MockLCManager())
        sut.attachView(venueViewMock)
        
        //when
        sut.getVenues(venue:  "", longitude: 12, latitude: 13)
        
        //verify
        XCTAssertTrue(venueViewMock.setEmptyVenuesCalled)
        XCTAssert(venueViewMock.finishLoadingCalled)
    }
    
    func testShouldShowNetworkError() {
        emptyVenuesServiceMock.errorType = VenueErrorType.Network
        let venueViewMock = VenueViewMock()
        let sut = VenuePresenter(venueService: emptyVenuesServiceMock, locationService: MockLCManager())
        sut.attachView(venueViewMock)
        
        //when
        sut.getVenues(venue:  "", longitude: 12, latitude: 13)
        
        XCTAssert(venueViewMock.networkErrorCalled)
    }
}

class testLocationService: XCTestCase {
    
    func testLocationService_with_permission() {
        let venueViewMock = VenueViewMock()
        
        let sut = VenuePresenter(venueService: MockVenueService(), locationService: MockLCManager())
        sut.attachView(venueViewMock)
        XCTAssert(MockLocationManager.locationServicesEnabled())
        XCTAssert(sut.isLocationEnabled())
        
        sut.showSelectedVenue(venue: "")
        XCTAssert(venueViewMock.locationNotAvailableCalled)
    }
    
    func testLocationService_without_Permission() {
        let venueViewMock = VenueViewMock()
        
        let sut = VenuePresenter(venueService: MockVenueService(), locationService: MockLCManagerDisableLocation())
        sut.attachView(venueViewMock)
        
        XCTAssertFalse(MockLCManagerDisableLocation.locationServicesEnabled())
        
        XCTAssert(!sut.isLocationEnabled())
        
        sut.showSelectedVenue(venue: "")
        XCTAssert(venueViewMock.locationDisableCalled)
    }
    
    func testLocationService_with_valid_location() {
        let venueViewMock = VenueViewMock()
        
        let sut = VenuePresenter(venueService: MockVenueService(), locationService: MockLCManager())
        sut.attachView(venueViewMock)
        XCTAssert(MockLCManager.locationServicesEnabled())
        XCTAssert(sut.isLocationEnabled())
        sut.locaionUpdated([CLLocation(latitude: 60.2365327, longitude: 24.782747)])
        sut.showSelectedVenue(venue: "")
        XCTAssert(!venueViewMock.locationNotAvailableCalled)
        XCTAssert(!venueViewMock.locationDisableCalled)
    }
    
    func testLocationService_location_will_be_fetched_after_view_isShown() {
        let venueViewMock = VenueViewMock()
        let lcManager = MockLCManager()
        
        let sut = VenuePresenter(venueService: MockVenueService(), locationService: lcManager)
        sut.attachView(venueViewMock)
        sut.viewWillAppear()
        XCTAssert(lcManager.requestWheInUseAuthorizationCalled)
        XCTAssert(lcManager.requestLocationCalled)
    }
    
}
