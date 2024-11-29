//
//  CitiesViewModel.swift
//  Cities
//
//  Created by andres martinez on 26/11/2024.
//

import Foundation

class CitiesViewModel: ObservableObject {

    @Published var cities: [CityViewDisplay] = []
    @Published var isLoading = true

    private var sortedCityDisplays: [CityViewDisplay] = []
    private var sortedFavoriteCityDisplays: [CityViewDisplay] = []
    private var searchHelper: CitiesSearchHelper?

    private var cityDisplaysDic: [Int: CityViewDisplay] = [:]
    private var favoritesCityDisplaysDic: [Int: CityViewDisplay] = [:]
    private let repository: Repository
    private var searchTask: Task<Void, Never>?
    private var favoriteIds = [Int]()
    private let favorite_user_defaults_key = "FAVORITE_CITIES"

    init(repository: Repository) {
        self.repository = repository
    }

    func getData() {
        isLoading = true
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self = self else { return }
            getFavoritesFromMemory()
            let citiesFromJson = getInitData()
            sortInitData(citiesFromJson)
            createFavoriteDisplays()

            await MainActor.run {
                guard !Task.isCancelled else { return }
                self.cities = self.sortedCityDisplays
                self.isLoading = false
            }
        }
    }

    func getInitData() -> [City] {
        repository.readCitiesFromBundle()?.data ?? []
    }

    func sortInitData(_ allCitiesFromJson: [City]) {
        let sortedCities = allCitiesFromJson.sorted {
            if $0.name == $1.name {
                return $0.country < $1.country
            }
            return $0.name < $1.name
        }
        // Populate searchHelper to make the filter by prefix works efficiently
        searchHelper = CitiesSearchHelper(cities: sortedCities.map { CityId(name: $0.name, id: $0.id) })
        sortedCityDisplays = sortedCities
            .map {
                CityViewDisplay(
                    name: $0.name,
                    country: $0.country,
                    coordinates: $0.coord,
                    id: $0.id,
                    isFav: favoriteIds.contains($0.id)
                )
            }
        sortedCityDisplays.forEach { display in
            self.cityDisplaysDic[display.id] = display
        }
    }

    func sortData(with prefix: String, onlyFavorites: Bool) {
        // Cancel any previous search
        searchTask?.cancel()

        if prefix == "" {
            if onlyFavorites {
                cities = sortedFavoriteCityDisplays
            } else {
                cities = sortedCityDisplays
            }
            return
        }

        searchTask = Task { [weak self] in
            guard let self = self else { return }
            guard let citiesToSearch = self.searchHelper?.search(with: prefix) else {
                await MainActor.run { self.cities = self.sortedCityDisplays }
                return
            }

            let cityIds = citiesToSearch
                .filter { [weak self] cityId in
                    if onlyFavorites {
                        return self?.favoritesCityDisplaysDic[cityId.id] != nil && cityId.name.hasPrefix(prefix)
                    }
                    return cityId.name.uppercased().hasPrefix(prefix.uppercased())
                }
            let results = cityIds.compactMap { self.cityDisplaysDic[$0.id] }

            await MainActor.run {
                guard !Task.isCancelled else { return }
                self.cities = results
            }
        }
    }

    func createFavoriteDisplays() {
        for id in favoriteIds {
            favoritesCityDisplaysDic[id] = cityDisplaysDic[id]
        }
        sortedFavoriteCityDisplays = favoritesCityDisplaysDic.values.sorted {
            if $0.name == $1.name {
                return $0.country < $1.country
            }
            return $0.name < $1.name
        }
    }

    func getFavoritesFromMemory() {
        favoriteIds = UserDefaults.standard.object(forKey: favorite_user_defaults_key) as? [Int] ?? []
    }

    func saveFavoritesOnMemory(_ favoriteIds: [Int]) {
        UserDefaults.standard.set(favoriteIds, forKey: favorite_user_defaults_key)
    }

    func setFavorite(id: Int, index: Int, isOnlyFav: Bool) {
        let display = cities[index]
        let newDisplay = CityViewDisplay(
            name: display.name,
            country: display.country,
            coordinates: display.coordinates,
            id: display.id,
            isFav: !display.isFav
        )
        if isOnlyFav {
            cities.remove(at: index)
        } else {
            cities[index] = newDisplay
        }
        cityDisplaysDic[newDisplay.id] = newDisplay
        favoritesCityDisplaysDic[newDisplay.id] = newDisplay

        if newDisplay.isFav {
            favoriteIds.append(id)
        } else {
            favoriteIds.removeAll { $0 == id }
        }
        createFavoriteDisplays()

        saveFavoritesOnMemory(favoriteIds)
    }
}

