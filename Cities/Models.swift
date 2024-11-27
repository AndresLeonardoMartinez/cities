//
//  Models.swift
//  Models
//
//  Created by andres martinez on 26/11/2024.
//

import Foundation

// MARK: - Cities
struct Cities: Codable {
    let data: [City]
}

// MARK: - City
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

// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double
}
