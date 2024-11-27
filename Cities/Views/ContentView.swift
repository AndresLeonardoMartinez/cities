//
//  ContentView.swift
//  Cities
//
//  Created by andres martinez on 26/11/2024.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var orientation = UIDevice.current.orientation
    @ObservedObject var viewModel: CitiesViewModel
    @State private var prefix: String = ""
    @State private var selectedCoordinates: MapCameraPosition?
    let delay: UInt64 = 300_000_000

    var body: some View {
        GeometryReader { geometry in
            let isPortrait = geometry.size.height > geometry.size.width
            if isPortrait {
                NavigationStack {
                    list
                }
            } else {
                HStack {
                    VStack {
                        filterView
                        ScrollView {
                            LazyVStack(alignment: .leading) {
                                ForEach(viewModel.searchingCityDisplays) { display in
                                    Button(action: {
                                        createMapPosition(coord: display.coordinates)
                                    }) {
                                        CityView(display: display)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: geometry.size.width * 0.4)
                    if let unwrappedCoordinates = Binding($selectedCoordinates) {
                        CityMap(position: unwrappedCoordinates)
                            .frame(maxWidth: geometry.size.width * 0.6)
                    } else {
                        Text("Select an city")
                            .frame(maxWidth: geometry.size.width * 0.6)
                    }
                }
            }
        }
        .onAppear {
            viewModel.getData()
        }
    }

    func createMapPosition(coord: Coord) {
        selectedCoordinates = MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: coord.lat,
                    longitude: coord.lon
                ),
                span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            )
        )
    }

    var list: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                VStack {
                    filterView
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            ForEach(viewModel.searchingCityDisplays) { display in
                                NavigationLink(value: display) {
                                    CityView(display: display)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Cities")
        .navigationDestination(for: CityViewDisplay.self) { display in
            Group {
                if let unwrappedCoordinates = Binding($selectedCoordinates) {
                    CityMap(position: unwrappedCoordinates)
                } else {
                    ProgressView()
                }
            }
            .onAppear() {
                createMapPosition(coord: display.coordinates)
            }
        }
    }

    var filterView: some View {
        TextField("City", text: $prefix)
            .onChange(of: prefix) {
                Task {
                    try? await Task.sleep(nanoseconds: delay)
                    await MainActor.run {
                        viewModel.sortData(with: prefix)
                    }
                }
            }
            .disableAutocorrection(true)
            .textFieldStyle(.roundedBorder)
            .padding()
    }
}