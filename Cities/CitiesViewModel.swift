//
//  CitiesViewModel.swift
//  Cities
//
//  Created by andres martinez on 26/11/2024.
//

import Foundation

class CitiesViewModel: ObservableObject {

    @Published var searchingCityDisplays: [CityViewDisplay] = []
    var allCityDisplays: [CityViewDisplay] = []
    @Published var isLoading = true
//    @Published var isSearching = true

    var searchHelper: CitiesSearchHelper?
    var allCityDisplaysDic: [Int: CityViewDisplay] = [:]
    let repository: Repository
    private var searchTask: Task<Void, Never>?


    init(repository: Repository) {
        self.repository = repository
    }

    func getData() {
        isLoading = true
        allCityDisplays = sortInitData(repository.readCitiesFromBundle()?.data ?? [])
        searchingCityDisplays = allCityDisplays
        allCityDisplays.forEach { display in
            allCityDisplaysDic[display.id] = display
        }
        isLoading = false
    }

    func sortInitData(_ allCities: [City]) -> [CityViewDisplay] {
        let sortedCities = allCities.sorted {
            if $0.name == $1.name {
                return $0.country < $1.country
            }
            return $0.name < $1.name
        }
        searchHelper = CitiesSearchHelper(cities: sortedCities.map { CityId(name: $0.name, id: $0.id) })
        return sortedCities
            .map {
            CityViewDisplay(
                name: $0.name,
                country: $0.country,
                coordinates: $0.coord,
                id: $0.id
            )
        }
    }

    func sortData(with prefix: String) {
        // Cancel any previous search
        searchTask?.cancel()

        if prefix == "" {
            searchingCityDisplays = allCityDisplays
            return
        }

        searchTask = Task { [weak self] in
            guard let self = self else { return }
            guard let citiesToSearch = self.searchHelper?.search(with: prefix) else {
                await MainActor.run { self.searchingCityDisplays = self.allCityDisplays }
                return
            }

            // Do expensive filtering on background thread
            let cityIds = citiesToSearch.filter { cityId in
                cityId.name.hasPrefix(prefix)
            }
            let results = cityIds.compactMap { self.allCityDisplaysDic[$0.id] }
            print(results.count)
            // Update UI on main thread
            await MainActor.run {
                guard !Task.isCancelled else { return }
                self.searchingCityDisplays = results
            }
        }
//        guard let citiesToSearch = searchHelper?.search(with: prefix) else {
//            searchingCityDisplays = allCityDisplays
//            return
//        }
//        searchingCityDisplays = []

//        var isStillSearching = true
//        var index = 0
//        var results = [CityViewDisplay]()
//
//        while isStillSearching && index < citiesToSearch.count {
//            let cityId = citiesToSearch[index]
//            if cityId.name.hasPrefix(prefix) {
//                if let city = allCityDisplaysDic[cityId.id] {
//                    results.append(city)
//                }
//                index += 1
//            } else {
//                if !results.isEmpty {
//                    isStillSearching = false
//                } else {
//                    index += 1
//                }
//            }
//        }
//        let cityIds = citiesToSearch.filter({ cityId in
//            cityId.name.hasPrefix(prefix)
//        })
//        let toReturn = cityIds.compactMap { allCityDisplaysDic[$0.id] }
//        
//        searchingCityDisplays = toReturn

//        searchingCityDisplays = results
    }

}

struct CityId {
    let name: String
    let id: Int
}

class CitiesSearchHelper {
    // Dictionary to store strings organized by their first character
    private var citiesByFirstLetter: [Character: [CityId]] = [:]

    init(cities: [CityId]) {
        let sortedCities = cities.sorted { $0.name < $1.name }
        // Group cities by their first character
        for city in sortedCities {
            guard let firstChar = city.name.first else { continue }

            if citiesByFirstLetter[firstChar] == nil {
                citiesByFirstLetter[firstChar] = []
            }
            citiesByFirstLetter[firstChar]?.append(city)
        }

//        // Optional: Sort arrays for each character
//        for (char, _) in citiesByFirstLetter {
//            citiesByFirstLetter[char]?.sort()
//        }
    }

    func search(with prefix: String) -> [CityId] {
        guard !prefix.isEmpty,
              let firstChar = prefix.first,
              let citiesWithFirstChar = citiesByFirstLetter[firstChar] else {
            return []
        }
        return citiesWithFirstChar
    }
}

