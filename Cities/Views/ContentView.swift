//
//  ContentView.swift
//  Cities
//
//  Created by andres martinez on 26/11/2024.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @ObservedObject var viewModel: CitiesViewModel
    @State private var orientation = UIDevice.current.orientation
    @State private var prefix: String = ""
    @State private var selectedCoordinates: MapCameraPosition?
    @State private var onlyFavorites: Bool = false

    let delay: UInt64 = 300_000_000

    var body: some View {
        GeometryReader { geometry in
            let isPortrait = geometry.size.height > geometry.size.width
            if viewModel.isLoading {
                ProgressView()
                    .tint(.blue)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                if isPortrait {
                    NavigationStack {
                        portraitView
                    }
                } else {
                    landscapeView(geometry)
                }
            }
        }
        .onAppear {
            viewModel.getData()
        }
        .onChange(of: onlyFavorites) {
            viewModel.sortData(with: prefix, onlyFavorites: onlyFavorites)
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

    var portraitView: some View {
        VStack {
            filterTextField
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(Array(viewModel.cities.enumerated()), id: \.element.id) { index, display in
                        NavigationLink(value: display) {
                            CityView(display: display, onTapFav: {
                                viewModel.setFavorite(id: display.id, index: index, isOnlyFav: onlyFavorites)
                            })
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }
                        .tint(.black)
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

    @ViewBuilder
    func landscapeView(_ geometry: GeometryProxy) -> some View {
        HStack {
            VStack {
                filterTextField
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(Array(viewModel.cities.enumerated()), id: \.element.id) { index, display in
                            Button(action: {
                                createMapPosition(coord: display.coordinates)
                            }) {
                                CityView(display: display, onTapFav: {
                                    viewModel.setFavorite(id: display.id, index: index, isOnlyFav: onlyFavorites)
                                })
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                            }
                            .tint(.black) 
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

    var filterTextField: some View {
        VStack {
            TextField("City", text: $prefix)
                .onChange(of: prefix) {
                    Task {
                        try? await Task.sleep(nanoseconds: delay)
                        await MainActor.run {
                            viewModel.sortData(with: prefix, onlyFavorites: onlyFavorites)
                        }
                    }
                }
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                .padding()
            HStack {
                Spacer()
                Toggle(isOn: $onlyFavorites, label: {
                    Text("Only favorites")
                })
                .tint(.blue)
            }
        }
    }
}
