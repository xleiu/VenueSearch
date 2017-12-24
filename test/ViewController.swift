//
//  ViewController.swift
//  test
//
//  Created by admin on 19/12/2017.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var venueTableView: UITableView!
    @IBOutlet weak var venueSelector: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let venues = ["food", "drinks", "coffee", "shops", "arts", "outdoors", "sights", "trending", "topPicks"]
    private let venuePresenter = VenuePresenter(venueService: FourSquareService(), locationService: CLLocationManager())
    private var venuesToDisplay = [VenueViewData]()
    
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        venueTableView.dataSource = (self as UITableViewDataSource)
        activityIndicator.hidesWhenStopped = true
        venuePresenter.attachView(self as VenueView)
        venueSelector.loadDropdownData(data: venues, onSelect: venue_onSelect)
        //venuePresenter.locService.delegate = self
        venueSelector.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        venuePresenter.requestLocationPermission()
        if (venuePresenter.isLocationEnabled()){
            venuePresenter.getCurrentLocation()
        }
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
            self.venuePresenter.getVenues(venue: selectedText,
                                          longitude: currentLocation!.coordinate.longitude,
                                          latitude: currentLocation!.coordinate.latitude)
        }
        else
        {
            venuePresenter.getCurrentLocation()
            showLocationAlert(false)
        }
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

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        if (!venueSelector.isUserInteractionEnabled) {
            venueSelector.isUserInteractionEnabled = true;
            venuePresenter.getVenues(venue: venues[0],
                                     longitude: currentLocation!.coordinate.longitude,
                                     latitude: currentLocation!.coordinate.latitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        print(status.hashValue)
        if (status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse) && currentLocation == nil {
            venuePresenter.getCurrentLocation()
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venuesToDisplay.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearchCell
        let venueViewData = venuesToDisplay[indexPath.row]
        cell.title.text = venueViewData.name
        cell.rating.text = String(venueViewData.rating) + "⭐️"
        cell.distance.text = String(venueViewData.distance) + "m"
        cell.address.text = venueViewData.address
        
        return cell
    }
}

extension ViewController: VenueView {
    func attachLocatoinDelegate(_ locationService: CLLocationManager) {
        locationService.delegate = self
    }
    
        
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
    
    
    
}
