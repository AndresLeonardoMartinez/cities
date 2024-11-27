//
//  Models.swift
//  Models
//
//  Created by andres martinez on 26/11/2024.
//

import Foundation

struct Cities: Codable {
    let data: [City]
}

struct City: Codable {
    let country, name: String
    let id: Int
    let coord: Coord

    enum CodingKeys: String, CodingKey {
        case country, name
        case id = "_id"
        case coord
    }
}

struct Coord: Codable, Hashable {
    let lon, lat: Double
}
