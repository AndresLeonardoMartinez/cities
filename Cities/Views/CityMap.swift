//
//  CityMap.swift
//  Cities
//
//  Created by andres martinez on 27/11/2024.
//

import SwiftUI
import MapKit

struct CityMap: View {
    @Binding var position: MapCameraPosition

    var body: some View {
        Map(position: $position)
    }
}
