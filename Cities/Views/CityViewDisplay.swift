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
    let isFav: Bool
}

struct CityView: View {
    let display: CityViewDisplay
    var onTapFav: () -> ()

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(display.name), \(display.country)")
                    .font(.headline)
                Text("\(display.coordinates.lat), \(display.coordinates.lon)")
                    .font(.subheadline)
            }
            Spacer()
            Button(action: {
                onTapFav()
            }) {
                Image(systemName: "heart")
                    .tint(display.isFav ? .red : .gray)
            }
        }
    }
}
