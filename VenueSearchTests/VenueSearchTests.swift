import XCTest
import CoreLocation

@testable import VenueSearch

class VenueServiceMock: VenueService {
    let venues: [Venue]
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
    var venueErrorCalled = false
    var locationErrorCalled = false
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
            
        case .JsonParse:
            venueErrorCalled = true
            
        case .Location:
            locationErrorCalled = true
            
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
    
    func testVenueCatelog() {
        let sut = makeSUT(false)
        let cat = sut.presenter.venueCatelogToShow()
        XCTAssertEqual(["food", "drinks", "coffee", "shops", "arts", "outdoors", "sights", "trending", "topPicks"], cat)
    }
    
    func testWithValidVenueShouldSetVenueView() {
        //given
        let sut = makeSUT(false)
        
        //when
        sut.presenter.locaionUpdated([CLLocation(latitude: 60.2365327, longitude: 24.782747)])
        sut.presenter.showSelectedVenue(venue: "something")
        
        //verify
        XCTAssertTrue(sut.view.setVenuesCalled)
        XCTAssertTrue(sut.view.finishLoadingCalled)
    }

    func testWithInvalidVenueInputShouldShowError() {
        //given
        let sut = makeSUT(true)
        
        //when
        sut.presenter.locaionUpdated([CLLocation(latitude: 60.2365327, longitude: 24.782747)])
        sut.presenter.showSelectedVenue(venue: "ö")
        
        //verify
        XCTAssertTrue(sut.view.venueErrorCalled)
        
        sut.view.venueErrorCalled = false
        sut.presenter.showSelectedVenue(venue: "")
        XCTAssertTrue(sut.view.venueErrorCalled)
    }

    func testWithEmptyVenueShouldClearVenueView() {
        let sut = makeSUT(true)
        
        //when
        sut.presenter.locaionUpdated([CLLocation(latitude: 60.2365327, longitude: 24.782747)])
        sut.presenter.showSelectedVenue(venue: "some")
        
        //verify
        XCTAssertTrue(sut.view.setEmptyVenuesCalled)
        XCTAssertTrue(sut.view.finishLoadingCalled)
    }
    
    func testWithoutNewtworkShouldShowNetworkError() {
        let sut = makeSUT(true)
        sut.service.errorType = .Network
        
        //when
        sut.presenter.locaionUpdated([CLLocation(latitude: 60.2365327, longitude: 24.782747)])
        sut.presenter.showSelectedVenue(venue: "something")
        
        //verify
        XCTAssertTrue(sut.view.networkErrorCalled)
    }
    
    func testTableViewDelegateNumberOfVenues() {
        let sut = makeSUT(false)
        sut.presenter.locaionUpdated([CLLocation(latitude: 60.2365327, longitude: 24.782747)])
        sut.presenter.showSelectedVenue(venue: "something")
        XCTAssertEqual(2, sut.presenter.numberOfVenues())
    }
    
//    func testTableViewDelegateConfigCell() {
//        let cell = SearchCell()
//        let sut = makeSUT(false)
//        sut.presenter.locaionUpdated([CLLocation(latitude: 60.2365327, longitude: 24.782747)])
//        sut.presenter.showSelectedVenue(venue: "something")
//        sut.presenter.configureCell(forRow: 0, cell: cell)
//        XCTAssertEqual(cell.address.text, sut.service.venues[0].address)
//        XCTAssertEqual(cell.title.text, sut.service.venues[0].name)
//        XCTAssertEqual(cell.distance.text, String(sut.service.venues[0].distance))
//        XCTAssertEqual(cell.rating.text, String(sut.service.venues[0].address))
//    }
    
    private func makeSUT(_ isEmpty: Bool) -> (presenter: VenuePresenter, view: VenueViewMock, service:VenueServiceMock) {
        let venueService = isEmpty ? emptyVenuesServiceMock : twoVenuesServiceMock
        let venueView = VenueViewMock()
        let venuePresenter = VenuePresenter(venueService: venueService, locationService: MockLCManager())
        venuePresenter.attachView(venueView)
        return (venuePresenter, venueView, venueService)
    }
}
extension String : Error {
    
}

class testLocationService: XCTestCase {
    
    func testLocationServiceWithoutPermissionShouldShowLocationDisabledError() {
        let sut = makeSUT(true)
        sut.presenter.showSelectedVenue(venue: "k")
        XCTAssertTrue(sut.view.locationDisableCalled)
    }
    
    func testLocationServiceWithPermissionWithoutValidLocationShouldShowLocationNotAvailableError() {
        let sut = makeSUT(false)
        sut.presenter.showSelectedVenue(venue: "s")
        XCTAssertTrue(sut.view.locationNotAvailableCalled)
    }
    
    func testLocationServiceWithValidLocationShouldNotShowError() {
        let sut = makeSUT(false)
        sut.presenter.locaionUpdated([CLLocation(latitude: 60.2365327, longitude: 24.782747)])
        sut.presenter.showSelectedVenue(venue: "b")
        XCTAssertFalse(sut.view.locationNotAvailableCalled)
        XCTAssertFalse(sut.view.locationDisableCalled)
    }
    
    func testLocationServiceLocationWillBeFetchedAfterViewIsShown() {
        let sut = makeSUT(false)
        sut.presenter.viewWillAppear()
        XCTAssert(sut.lc.requestWheInUseAuthorizationCalled)
        XCTAssert(sut.lc.requestLocationCalled)
    }
    
    func testLocationSerivceLocationUpdateWillTriggerFetchVenueForTheFirstTime() {
        let sut = makeSUT(false)
        sut.view.isVenueSelectorEnabled = false
        sut.presenter.locaionUpdated([CLLocation(latitude: 60.2365327, longitude: 24.782747)])
        XCTAssertTrue(sut.view.isVenueSelectorEnabled)
    }
    
    func testLocationServiceLocationAuthorizationChangedWillTriggerFetchLoaction() {
        let sut = makeSUT(false)
        sut.presenter.locationAuthorizationChanged(.authorizedWhenInUse)
        XCTAssertTrue(sut.lc.requestLocationCalled)
        
        sut.lc.requestLocationCalled = false
        sut.presenter.locationAuthorizationChanged(.authorizedWhenInUse)
        XCTAssertTrue(sut.lc.requestLocationCalled)
    }
    
    func testLocationServiceErrorWillTriggerAlert() {
        let sut = makeSUT(false)
        sut.presenter.locationError("location error")
        XCTAssertTrue(sut.view.locationErrorCalled)
    }
    
    private func makeSUT(_ disable: Bool) -> (presenter: VenuePresenter, lc: MockLCManager, view: VenueViewMock) {
        let venueViewMock = VenueViewMock()
        let lcManager = disable ? MockLCManagerDisableLocation() : MockLCManager()
        let presenter = VenuePresenter(venueService: MockVenueService(), locationService: lcManager)
        presenter.attachView(venueViewMock)
        return (presenter, lcManager, venueViewMock)
    }
    
}
