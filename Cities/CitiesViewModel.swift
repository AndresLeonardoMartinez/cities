//
//  CitiesViewModel.swift
//  Cities
//
//  Created by andres martinez on 26/11/2024.
//

import Foundation

class CitiesViewModel: ObservableObject {

    @Published var searchingCityDisplays: [CityViewDisplay] = []
    @Published var isLoading = true

    private var allCityDisplays: [CityViewDisplay] = []
    private var allFavoriteCityDisplays: [CityViewDisplay] = []
    private var searchHelper: CitiesSearchHelper?

    private var allCityDisplaysDic: [Int: CityViewDisplay] = [:]
    private var allFavoritesCityDisplaysDic: [Int: CityViewDisplay] = [:]
    private let repository: Repository
    private var searchTask: Task<Void, Never>?
    private var favoriteIds = [Int]()
    private let favorite_user_defaults_key = "FAVORITE_CITIES"

    init(repository: Repository) {
        self.repository = repository
    }

    func getData() {
        isLoading = true
        favoriteIds = UserDefaults.standard.object(forKey: favorite_user_defaults_key) as? [Int] ?? []
        allCityDisplays = sortInitData(repository.readCitiesFromBundle()?.data ?? [])
        searchingCityDisplays = allCityDisplays
        allCityDisplays.forEach { display in
            allCityDisplaysDic[display.id] = display
        }
        getFavoritesIds()
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
                    id: $0.id,
                    isFav: favoriteIds.contains($0.id)
                )
            }
    }

    func getFavoritesIds() {
        for id in favoriteIds {
            allFavoritesCityDisplaysDic[id] = allCityDisplaysDic[id]
        }
        allFavoriteCityDisplays = allFavoritesCityDisplaysDic.values.sorted {
            if $0.name == $1.name {
                return $0.country < $1.country
            }
            return $0.name < $1.name
        }
    }

    func sortData(with prefix: String, onlyFavorites: Bool) {
        // Cancel any previous search
        searchTask?.cancel()

        if prefix == "" {
            if onlyFavorites {
                searchingCityDisplays = allFavoriteCityDisplays
            } else {
                searchingCityDisplays = allCityDisplays
            }
            return
        }

        searchTask = Task { [weak self] in
            guard let self = self else { return }
            guard let citiesToSearch = self.searchHelper?.search(with: prefix) else {
                await MainActor.run { self.searchingCityDisplays = self.allCityDisplays }
                return
            }

            let cityIds = citiesToSearch
                .filter { [weak self] cityId in
                    if onlyFavorites {
                        return self?.allFavoritesCityDisplaysDic[cityId.id] != nil && cityId.name.hasPrefix(prefix)
                    }
                    return cityId.name.hasPrefix(prefix)
                }
            let results = cityIds.compactMap { self.allCityDisplaysDic[$0.id] }
            print(results.count)
            // Update UI on main thread
            await MainActor.run {
                guard !Task.isCancelled else { return }
                self.searchingCityDisplays = results
            }
        }
    }

    func setFavorite(id: Int, index: Int, isOnlyFav: Bool) {
        let display = searchingCityDisplays[index]
        let newDisplay = CityViewDisplay(
            name: display.name,
            country: display.country,
            coordinates: display.coordinates,
            id: display.id,
            isFav: !display.isFav
        )
        if isOnlyFav {
            searchingCityDisplays.remove(at: index)
        } else {
            searchingCityDisplays[index] = newDisplay
        }
        allCityDisplaysDic[newDisplay.id] = newDisplay
        allFavoritesCityDisplaysDic[newDisplay.id] = newDisplay
        
        let isFav = !display.isFav
        if isFav {
            favoriteIds.append(id)
        } else {
            favoriteIds.removeAll{ $0 == id }
        }
        getFavoritesIds()

        UserDefaults.standard.set(favoriteIds, forKey: favorite_user_defaults_key)
    }
}

