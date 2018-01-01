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

class VenueViewMock : NSObject, VenueView{
    func attachLocatoinDelegate(_ locationService: CLLocationManager) {
        
    }
    
    func startLoading() {
        startLoadingCalled = true
    }
    
    func finishLoading() {
        finishLoadingCalled = true
    }
    
    func setVenues(_ venues: [VenueViewData]) {
        setVenuesCalled = true
    }
    
    func setEmptyVenues() {
        setEmptyVenuesCalled = true
    }
    
    var setVenuesCalled = false
    var setEmptyVenuesCalled = false
    var startLoadingCalled = false
    var finishLoadingCalled = false
    
}
class VenuePresenterTest: XCTestCase {
    
    let emptyVenuesServiceMock = VenueServiceMock(venues: [Venue]())
    
    let twoVenuesServiceMock = VenueServiceMock(venues: [Venue(name: "name1", address: "address1", distance: 300, rating: 8),
                                                     Venue(name: "name2", address: "address2", distance: 200, rating: 5)])
    
    func testShouldSetVenues() {
        //given
        let venueViewMock = VenueViewMock()
        let sut = VenuePresenter(venueService: twoVenuesServiceMock, locationService: MockLocationManager())
        sut.attachView(venueViewMock)
        
        //when
        sut.getVenues(venue:  "", longitude: 12, latitude: 13)
        
        //verify
        XCTAssertTrue(venueViewMock.setVenuesCalled)
        XCTAssert(venueViewMock.finishLoadingCalled)
    }
    
    func testShouldClearVenues() {
        let venueViewMock = VenueViewMock()
        let sut = VenuePresenter(venueService: emptyVenuesServiceMock, locationService: MockLocationManager())
        sut.attachView(venueViewMock)
        
        //when
        sut.getVenues(venue:  "", longitude: 12, latitude: 13)
        
        //verify
        XCTAssertTrue(venueViewMock.setEmptyVenuesCalled)
        XCTAssert(venueViewMock.finishLoadingCalled)
    }
}

class testLocationService: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLocationService() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let sut = VenuePresenter(venueService: MockVenueService(), locationService: MockLocationManager())
        XCTAssert(MockLocationManager.locationServicesEnabled())
        XCTAssert(sut.isLocationEnabled())
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
