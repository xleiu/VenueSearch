import Foundation

struct Venue
{
    let name: String
    let address: String
    let distance: Int
    let rating: Double
}

protocol VenueService
{
    func getVenues(vanue: String, longtitute: Double, latitute: Double, _ callBack: @escaping ([Venue])-> Void)
}

class FourSquareService : VenueService
{
    let client_id = ""
    let client_secret = ""

    func getVenues(vanue venue: String, longtitute longtitude: Double, latitute latitude: Double, _ callBack: @escaping ([Venue])-> Void)
    {
        let url = "https://api.foursquare.com/v2/venues/explore?ll=\(latitude),\(longtitude)&v=20171220&section=\(venue)&limit=15&client_id=\(client_id)&client_secret=\(client_secret)"
        print(url)
        let request = NSMutableURLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, err -> Void in
            let json = JSON(data: data!)
            let venue = json["response"]["groups"][0]["items"].arrayValue
            
            let venueResult = venue.map {(value: JSON) in
                return Venue(name: value["venue"]["name"].string == nil ? "unknown" : value["venue"]["name"].string!,
                             address: value["venue"]["location"]["address"].string == nil ? "unknown" : value["venue"]["location"]["address"].string!,
                             distance: value["venue"]["location"]["distance"].intValue,
                             rating: value["venue"]["rating"].doubleValue)
            }
            callBack(venueResult)
        })
        task.resume()
    }
}

class MockVenueService : VenueService
{
    func getVenues(vanue venue: String, longtitute longtitude: Double, latitute latitude: Double, _ callBack: @escaping ([Venue])-> Void)
    {
        let venues = [Venue(name: "test1", address: "espoo", distance: 10, rating: 2.3), Venue(name: "test2", address: "Helsinki", distance: 199, rating: 4.5)]
        let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            callBack(venues)
        } 
    }
}
