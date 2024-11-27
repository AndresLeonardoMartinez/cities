//
//  CitiesApp.swift
//  Cities
//
//  Created by andres martinez on 26/11/2024.
//

import SwiftUI

@main
struct CitiesApp: App {
    let repository = Repository()
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: CitiesViewModel(repository: repository))
        }
    }
}
