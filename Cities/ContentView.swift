//
//  ContentView.swift
//  Cities
//
//  Created by andres martinez on 26/11/2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: CitiesViewModel
    @State private var prefix: String = ""
    @FocusState private var isPrefixFocused: Bool

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                VStack {
                    TextField("City", text: $prefix)
                        .focused($isPrefixFocused)
                        .onChange(of: prefix) {
                            viewModel.sortData(with: prefix)
                        }
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    List {
                        ForEach(
                            viewModel.isSearching ? viewModel.cities : viewModel.allCitiesSorted,
                            id: \.id
                        ) { city in
                            Text("\(city.name), \(city.country)")
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.getData()
        }
    }
}
