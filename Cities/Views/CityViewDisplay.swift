//
//  CityViewDisplay.swift
//  Cities
//
//  Created by andres martinez on 27/11/2024.
//

import SwiftUI

struct CityViewDisplay: Identifiable, Hashable {
    let name: String
    let country: String
    let coordinates: Coord
    let id: Int
}

struct CityView: View {
    let display: CityViewDisplay

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(display.name), \(display.country)")
                    .font(.headline)
                Text("\(display.coordinates.lat), \(display.coordinates.lon)")
                    .font(.subheadline)
            }
        }
    }
}
