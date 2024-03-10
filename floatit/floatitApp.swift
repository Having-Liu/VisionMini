//
//  floatitApp.swift
//  floatit
//
//  Created by 自在 on 2024/3/10.
//

import SwiftUI

@main
struct floatitApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
