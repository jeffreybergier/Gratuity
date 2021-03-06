//
//  JSBIPGeocoder.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/30/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

public enum JSBIPGeoService {
    case any
    case all
    case freeGeoIP
    case telize
}

public protocol JSBIPGeocoderServiceable {
    var urls: [URL] { get }
    var exhaustive: Bool { get}
}

extension JSBIPGeoService: JSBIPGeocoderServiceable {
    public var urls: [URL] {
        switch self {
        case .telize:
            return [self.telizeURL]
        case .freeGeoIP:
            return [self.freeGeoIPURL]
        default:
            return [self.freeGeoIPURL, self.telizeURL]
        }
    }
    
    public var exhaustive: Bool {
        switch self {
        case .all:
            return true
        default:
            return false
        }
    }
    
    fileprivate var freeGeoIPURL: URL! { return URL(string: "https://freegeoip.net/json/") }
    fileprivate var telizeURL: URL! { return URL(string: "https://www.telize.com/geoip/") }
}

public protocol JSBIPGeocoderLocatable {
    var isEmpty: Bool { get }
    mutating func addJSONDictionary(_ dictionary: NSDictionary)
}

public struct JSBIPLocation: JSBIPGeocoderLocatable {
    public var ip: String?
    public var zipCode: String?
    public var city: String?
    public var region: String?
    public var country: String?
    public var countryCode: String?
    public var regionCode: String?
    public var timeZone: String?
    public var latitude: String?
    public var longitude: String?
    public var metroCode: String?
    public var continent: String?
    public var areaCode: String?
    public var isp: String?
    
    public var isEmpty: Bool {
        var empty = true
        if let _ = self.ip {
            empty = false
        }
        if let _ = self.zipCode {
            empty = false
        }
        if let _ = self.city {
            empty = false
        }
        if let _ = self.region {
            empty = false
        }
        if let _ = self.country {
            empty = false
        }
        if let _ = self.countryCode {
            empty = false
        }
        if let _ = self.regionCode {
            empty = false
        }
        if let _ = self.timeZone {
            empty = false
        }
        if let _ = self.latitude {
            empty = false
        }
        if let _ = self.longitude {
            empty = false
        }
        if let _ = self.metroCode {
            empty = false
        }
        if let _ = self.continent {
            empty = false
        }
        if let _ = self.areaCode {
            empty = false
        }
        if let _ = self.isp {
            empty = false
        }
        return empty
    }
}

extension JSBIPLocation {
    mutating public func addJSONDictionary(_ dictionary: NSDictionary) {
        
        //case .FreeGeoIP:
        if let ip = dictionary["ip"] as? String {
            self.ip = ip
        }
        if let country_code = dictionary["country_code"] as? String {
            self.countryCode = country_code
        }
        if let country_name = dictionary["country_name"] as? String {
            self.country = country_name
        }
        if let region_code = dictionary["region_code"] as? String {
            self.regionCode = region_code
        }
        if let region_name = dictionary["region_name"] as? String {
            self.region = region_name
        }
        if let city = dictionary["city"] as? String {
            self.city = city
        }
        if let zip_code = dictionary["zip_code"] as? String {
            self.zipCode = zip_code
        }
        if let time_zone = dictionary["time_zone"] as? String {
            self.timeZone = time_zone
        }
        if let latitude = dictionary["latitude"] as? String {
            self.latitude = latitude
        }
        if let longitude = dictionary["longitude"] as? String {
            self.longitude = longitude
        }
        if let metro_code = dictionary["metro_code"] as? String {
            self.metroCode = metro_code
        }
        
        //case .Telize:
        if let ip = dictionary["ip"] as? String {
            self.ip = ip
        }
        if let country_code = dictionary["country_code"] as? String {
            self.countryCode = country_code
        }
        if let country = dictionary["country"] as? String {
            self.country = country
        }
        if let region_code = dictionary["region_code"] as? String {
            self.regionCode = region_code
        }
        if let region = dictionary["region"] as? String {
            self.region = region
        }
        if let city = dictionary["city"] as? String {
            self.city = city
        }
        if let postal_code = dictionary["postal_code"] as? String {
            self.zipCode = postal_code
        }
        if let continent_code = dictionary["continent_code"] as? String {
            self.continent = continent_code
        }
        if let latitude = dictionary["latitude"] as? String {
            self.latitude = latitude
        }
        if let longitude = dictionary["longitude"] as? String {
            self.longitude = longitude
        }
        if let area_code = dictionary["area_code"] as? String {
            self.areaCode = area_code
        }
        if let isp = dictionary["isp"] as? String {
            self.isp = isp
        }
        if let timezone = dictionary["timezone"] as? String {
            self.timeZone = timezone
        }
    }
}
