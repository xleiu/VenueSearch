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
    
    @IBAction func custmizedVenue(_ sender: UITextField) {
        
    }
    
    private let venuePresenter = VenuePresenter(venueService: FourSquareService(), locationService: CLLocationManager())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        venueTableView.dataSource = (self as UITableViewDataSource)
        activityIndicator.hidesWhenStopped = true
        venuePresenter.attachView(self as VenueView)
        venueSelector.loadDropdownData(data: venuePresenter.venueCatelogToShow(), onSelect: venue_onSelect)
        venueSelector.delegate = self
        venueSelector.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        venuePresenter.viewWillAppear()
    }
    
    func venue_onSelect(selectedText: String) {
        self.venueSelector.resignFirstResponder()
        venuePresenter.showSelectedVenue(venue: selectedText)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        venuePresenter.locaionUpdated(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        venuePresenter.locationError(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        venuePresenter.locationAuthorizationChanged(status)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        venueSelector.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        venuePresenter.showSelectedVenue(venue: textField.text!)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venuePresenter.numberOfVenues()
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearchCell
        venuePresenter.configure(forRow: indexPath.row, cell: cell)
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
        
    func setVenues(_ empty: Bool) {
        DispatchQueue.main.async {
            self.venueTableView.isHidden = !empty
            self.venueTableView.reloadData()
        }
    }
    
    var isVenueSelectorEnabled: Bool {
        get { return venueSelector.isUserInteractionEnabled }
        set { venueSelector.isUserInteractionEnabled = newValue }
    }
    
    func showLocationAlert(_ disabled: Bool) {
        let title = disabled ? String("Location Disabled") : String("Getting locations")
        let message = disabled ? String("Please enable location") : String("Please waiting for location")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
