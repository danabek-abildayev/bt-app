//
//  MainView.swift
//  BTproject
//
//  Created by Danabek Abildayev on 24.12.2024.
//

import CoreData
import SwiftUI

struct MainView: View {
    let context: NSManagedObjectContext

    var body: some View {
        TabView {
            BluetoothView(context: context)
                .tabItem {
                    Label("BT devices", systemImage: "dot.radiowaves.left.and.right")
                }

            ScanHistoryView(context: context)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    return MainView(context: context)
}
