//
//  ViewController.swift
//  test
//
//  Created by admin on 19/12/2017.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var venueTableView: UITableView!
    @IBOutlet weak var venueSelector: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate let venues = ["food", "drinks", "coffee", "shops", "arts", "outdoors", "sights", "trending", "topPicks"]
    fileprivate let venuePresenter = VenuePresenter(venueService: RealFSS(), locationService: MockLocationManager())
    fileprivate var venuesToDisplay = [VenueViewData]()
    
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        venueTableView.dataSource = (self as UITableViewDataSource)
        activityIndicator.hidesWhenStopped = true
        venuePresenter.attachView(self as VenueView)
        venueSelector.loadDropdownData(data: venues, onSelect: venue_onSelect)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // request location access
        venuePresenter.requestLocationPermission()
    }
    
    func venue_onSelect(selectedText: String) {
        self.venueSelector.resignFirstResponder()
        if (!venuePresenter.isLocationEnabled())
        {
            showLocationAlert(true)
            return;
        }
        if (currentLocation != nil)
        {
            self.venuePresenter.getVenues(venue: selectedText, loc: currentLocation!)
        }
        else
        {
            self.venuePresenter.getCurrentLocation()
            showLocationAlert(false)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showLocationAlert(_ disabled: Bool) -> Void {
        let title = disabled ? String("Location Disabled") : String("Getting locations")
        let message = disabled ? String("Please enable location") : String("Please waiting for location")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venuesToDisplay.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "UserCell")
        let venueViewData = venuesToDisplay[indexPath.row]
        cell.textLabel?.text = venueViewData.name + "           " + String(venueViewData.rating)
        cell.detailTextLabel?.text = venueViewData.address + "          " + String(venueViewData.distance) + " m"
        
        return cell
    }
}

extension ViewController: VenueView {
        
    func startLoading() {
        activityIndicator.startAnimating()
    }
        
    func finishLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
        
    func setVenues(_ venues: [VenueViewData]) {
        DispatchQueue.main.async {
            self.venuesToDisplay = venues
            self.venueTableView.isHidden = false
           self.venueTableView.reloadData()
        }
    }
        
    func setEmptyVenues() {
        DispatchQueue.main.async {
            self.venueTableView.isHidden = true
        }
    }
    
    func setLocation(_ location: CLLocation) {
        currentLocation = location
    }
}
