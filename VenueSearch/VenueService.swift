import Foundation

struct Venue {
    let name: String
    let address: String
    let distance: Int
    let rating: Double
}

protocol VenueService {
    func getVenues(vanue: String, longtitute: Double, latitute: Double, _ callBack: @escaping ([Venue], String, VenueErrorType)-> Void)
}

class FourSquareService : VenueService {
    let client_id = FourSqureClient.client_id
    let client_secret = FourSqureClient.client_secret
    let venue_limit = FourSqureClient.venue_limit

    func getVenues(vanue venue: String, longtitute longtitude: Double, latitute latitude: Double, _ callBack: @escaping ([Venue], String, VenueErrorType)-> Void) {
        let url = "https://api.foursquare.com/v2/venues/explore?ll=\(latitude),\(longtitude)&v=20171220&section=\(venue)&limit=\(venue_limit)&client_id=\(client_id)&client_secret=\(client_secret)"
        print(url)
        let request = NSMutableURLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, err -> Void in
            if err != nil {
                callBack([Venue](), err!.localizedDescription, .Network)
                return
            }
            guard let data = data else {
                callBack([Venue](), "json data is empty", VenueErrorType.JsonParse)
                return
            }
            let json = JSON(data: data)
            let venue = json["response"]["groups"][0]["items"].arrayValue
            
            let venueResult = venue.map {
                return Venue(name: $0["venue"]["name"].string ?? "unknown",
                             address: $0["venue"]["location"]["address"].string ?? "unknown",
                             distance: $0["venue"]["location"]["distance"].intValue,
                             rating: $0["venue"]["rating"].doubleValue)
            }
            callBack(venueResult, "", .None)
        })
        task.resume()
    }
}

class MockVenueService : VenueService {
    func getVenues(vanue venue: String, longtitute longtitude: Double, latitute latitude: Double, _ callBack: @escaping ([Venue], String, VenueErrorType)-> Void) {
        var venues = [Venue]()
        let range = 0...20
        for (n, _) in range.enumerated() {
            var longString = String(n)
            for _ in 0..<n {
                longString += String(n)
            }
            venues.append(Venue(name: "test" + longString, address: "espoo " + longString, distance: 10, rating: 2.3))
        }
        let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            callBack(venues, "", .None)
        } 
    }
}
