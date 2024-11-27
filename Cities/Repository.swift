//
//  Repository.swift
//  Cities
//
//  Created by andres martinez on 27/11/2024.
//
import Foundation

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
