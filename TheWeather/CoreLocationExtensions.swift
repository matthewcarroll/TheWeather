//
//  CoreLocationExtensions.swift
//  TheWeather WatchKit Extension
//
//  Created by Matthew Carroll on 4/27/16.
//  Copyright © 2016 The Weather Channel. All rights reserved.
//

import CoreLocation

extension CLLocation {
    
    var coordinateString: String { get {
        let latitude = String(format: "%.2f", coordinate.latitude)
        let longitude = String(format: "%.2f", coordinate.longitude)
        return "\(latitude),\(longitude)"
        }
    }
}

extension CLLocationCoordinate2D {
    
    var asString: String { get {
        let _latitude = String(format: "%.2f", latitude)
        let _longitude = String(format: "%.2f", longitude)
        return "\(_latitude),\(_longitude)"
        }
    }
    
    init?(string: String) {
        let components = string.components(separatedBy: ",")
        let lat = components.first?.trimmingCharacters(in: CharacterSet.whitespaces)
        let long = components.last?.trimmingCharacters(in: CharacterSet.whitespaces)
        guard let latD = CLLocationDegrees(lat ?? ""), let longD = CLLocationDegrees(long ?? "") else { return nil }
        self.init(latitude: latD, longitude: longD)
    }
}

extension CLLocationCoordinate2D {
    
    var radiansLatitude: CLLocationDirection {
        return latitude * M_PI / 180
    }
    
    var radiansLongitude: CLLocationDirection {
        return longitude * M_PI / 180
    }
}

extension CLLocationCoordinate2D {
    
    func compassDirection(to coordinate: CLLocationCoordinate2D) -> CompassDirection {
        let differenceLat = log(tan(coordinate.radiansLatitude / 2 + M_PI / 4) / tan(radiansLatitude / 2 + M_PI / 4))
        var differenceLong = coordinate.radiansLongitude - radiansLongitude
        if abs(differenceLong) > M_PI {
            if differenceLong > 0 {
                differenceLong = (2 * M_PI - differenceLong) * -1
            }
            else {
                differenceLong = 2 * M_PI + differenceLong
            }
        }
        let deg = rad2Deg(radians: atan2(differenceLong, differenceLat))
        let angle = (deg + 360.0).truncatingRemainder(dividingBy: 360)
        return CompassDirection(directionDegrees: angle)
    }
    
    private func rad2Deg(radians: Double) -> CLLocationDegrees {
        return radians * 180 / M_PI
    }
}

enum CompassDirection {
    case N
    case NNE
    case NE
    case ENE
    case E
    case ESE
    case SE
    case SSE
    case S
    case SSW
    case SW
    case WSW
    case W
    case WNW
    case NW
    case NNW
}

extension CompassDirection {
    
    init(directionDegrees: CLLocationDegrees) {
        let direction = Int(round(directionDegrees / 22.5))
        switch direction {
        case 1: self = .NNE
        case 2: self = .NE
        case 3: self = .ENE
        case 4: self = .E
        case 5: self = .ESE
        case 6: self = .SE
        case 7: self = .SSE
        case 8: self = .S
        case 9: self = .SSW
        case 10: self = .SW
        case 11: self = .WSW
        case 12: self = .W
        case 13: self = .WNW
        case 14: self = .NW
        case 15: self = .NNW
        default: self = .N
        }
    }
    
    var localizedDirection: String {
        let key: String
        switch self {
        case .N: key = "direction.north"
        case .NNE: key = "direction.north-northeast"
        case .NE: key = "direction.northeast"
        case .ENE: key = "direction.east-northeast"
        case .E: key = "direction.east"
        case .ESE: key = "direction.east-southeast"
        case .SE: key = "direction.southeast"
        case .SSE: key = "direction.south-southeast"
        case .S: key = "direction.south"
        case .SSW: key = "direction.south-southwest"
        case .SW: key = "direction.southwest"
        case .WSW: key = "direction.west-southwest"
        case .W: key = "direction.west"
        case .WNW: key = "direction.west-northwest"
        case .NW: key = "direction.northwest"
        case .NNW: key = "direction.north-northwest"
        }
        return NSLocalizedString(key: key)
    }
}
