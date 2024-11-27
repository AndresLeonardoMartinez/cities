//
//  CitiesViewModel.swift
//  Cities
//
//  Created by andres martinez on 26/11/2024.
//

import Foundation

class CitiesViewModel: ObservableObject {

    @Published var cities: [City] = []
    @Published var allCitiesSorted: [City] = []
    @Published var isLoading = true
    @Published var isSearching = true

    let repository: Repository

    init(repository: Repository) {
        self.repository = repository
    }

    func getData() {
        isLoading = true
        allCitiesSorted = sortInitData(repository.readCitiesFromBundle()?.data ?? [])
        cities = allCitiesSorted
        isLoading = false
    }

    func sortInitData(_ allCities: [City]) -> [City] {
        allCities.sorted {
            $0.name < $1.name
        }
    }

    func sortData(with prefix: String) {
        if prefix == "" {
            isSearching = false
            return
        }
        isSearching = true

        var isStillSearching = true
        var index = 0
        var results = [City]()

        while isStillSearching && index < allCitiesSorted.count {
            let city = allCitiesSorted[index]
            if city.name.hasPrefix(prefix) {
                results.append(city)
                index += 1
            } else {
                if !results.isEmpty {
                    isStillSearching = false
                } else {
                    index += 1
                }
            }
        }
        cities = results
    }

}

class Repository {

    func readCitiesFromBundle() -> Cities? {
        guard let url = Bundle.main.url(forResource: "cities", withExtension: "json") else {
            return nil
        }
        return try? readJSONFile(with: url)
    }

    func readJSONFile<T: Decodable>(with url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

}
