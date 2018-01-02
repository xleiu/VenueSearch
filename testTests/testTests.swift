//
//  testTests.swift
//  testTests
//
//  Created by admin on 19/12/2017.
//  Copyright © 2017 admin. All rights reserved.
//

import XCTest
import CoreLocation

@testable import test

class VenueServiceMock: VenueService {
    private let venues: [Venue]
    
    init(venues: [Venue]) {
        self.venues = venues
    }
    
    func getVenues(vanue: String, longtitute: Double, latitute: Double, _ callBack: @escaping ([Venue])-> Void) {
        callBack(self.venues)
    }
    
}

class VenueViewMock : NSObject, VenueView {
    var setVenuesCalled = false
    var setEmptyVenuesCalled = false
    var startLoadingCalled = false
    var finishLoadingCalled = false
    var locationNotAvailableCalled = false
    var locationDisableCalled = false
    
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
    
    func showLocationAlert(_ errorType: Bool) {
        if (errorType) {
            locationDisableCalled = true
        } else {
            locationNotAvailableCalled = true
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
    
    func testLocationService_related_function_called() {
        let venueViewMock = VenueViewMock()
        let lcManager = MockLCManager()
        
        let sut = VenuePresenter(venueService: MockVenueService(), locationService: lcManager)
        sut.attachView(venueViewMock)
        sut.viewWillAppear()
        XCTAssert(lcManager.requestWheInUseAuthorizationCalled)
        XCTAssert(lcManager.requestLocationCalled)
    }
    
}
