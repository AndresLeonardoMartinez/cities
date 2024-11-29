//
//  CitiesSearchHelper.swift
//  Cities
//
//  Created by andres martinez on 27/11/2024.
//
struct CityId {
    let name: String
    let id: Int
}

/// CitiesSearchHelper is a helper to make the filter by prefix works efficiently. Basically it's a dic to store arrays of city names by its firts name.
/// In this way when we need to filter by prefix isntead of looking for the huge array of cities we just search in the array of the first letter
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

