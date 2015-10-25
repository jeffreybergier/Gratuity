//
//  GratuitousAppDelegate+Location.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/24/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

class GratuitousIPGeolocator {
    
    private var geocodeLocations: [Location] = []
    private var geocodeRequestsInProgress = 0
    
    func getIPLocation(completionHandler: Location? -> ()) {
        
        let geoCompletionHandler = { (success: Bool, coder: FCIPAddressGeocoder?) -> Void in
            self.geocodeRequestsInProgress--
            if let location = coder?.locationValue {
                self.geocodeLocations.append(location)
            }
            if self.geocodeRequestsInProgress == 0 {
                completionHandler(Location.merge(self.geocodeLocations))
                self.geocodeLocations = []
            }
        }
        
        if let locator = FCIPAddressGeocoder(service: FCIPAddressGeocoderServiceFreeGeoIP) {
            self.geocodeRequestsInProgress++
            locator.geocode(geoCompletionHandler)
        }
        
        if let locator = FCIPAddressGeocoder(service: FCIPAddressGeocoderServiceTelize) {
            self.geocodeRequestsInProgress++
            locator.geocode(geoCompletionHandler)
        }
    }
}

extension FCIPAddressGeocoder {
    var locationValue: Location? {
        var location = Location()
        if let zipCode = self.locationZipCode {
            location.zipCode = zipCode
        }
        if let city = self.locationCity {
            location.city = city
        }
        if let region = self.locationRegion {
            location.region = region
        }
        if let country = self.locationCountry {
            location.country = country
        }
        if let countryCode = self.locationCountryCode {
            location.countryCode = countryCode
        }
        if location.containsAnyValues() == true {
            return location
        } else {
            return .None
        }
    }
}

extension Location {
    static func merge(locations: [Location]?) -> Location? {
        var outputLocation = Location()
        
        locations?.forEach() { location in
            if let zipCode = location.zipCode {
                outputLocation.zipCode = zipCode
            }
            if let city = location.city {
                outputLocation.city = city
            }
            if let country = location.country {
                outputLocation.country = country
            }
            if let countryCode = location.countryCode {
                outputLocation.countryCode = countryCode
            }
        }
    
        if outputLocation.containsAnyValues() {
            return outputLocation
        } else {
            return .None
        }
    }
}