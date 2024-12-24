//
//  BTprojectApp.swift
//  BTproject
//
//  Created by Danabek Abildayev on 23.12.2024.
//

import SwiftUI
import CoreBluetooth

@main
struct BTprojectApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainView(context: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
