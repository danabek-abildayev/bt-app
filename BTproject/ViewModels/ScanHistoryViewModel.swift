//
//  ScanHistoryViewModel.swift
//  BTproject
//
//  Created by Danabek Abildayev on 24.12.2024.
//

import CoreData
import SwiftUI

class ScanHistoryViewModel: ObservableObject {
    @Published var scanHistory: [ScanHistoryModel] = []
    @Published var filteredHistory: [ScanHistoryModel] = []
    @Published var filterText: String = ""
    @Published var filterDate: Date?

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchScanHistory()
    }

    func fetchScanHistory() {
        let request: NSFetchRequest<ScanHistory> = ScanHistory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        do {
            let results = try context.fetch(request)
            scanHistory = results.map { ScanHistoryModel(
                id: $0.id ?? UUID(),
                timestamp: $0.timestamp ?? Date(),
                deviceName: $0.deviceName ?? "Unnamed device"
            ) }
            applyFilter()
        } catch {
            print("Ошибка загрузки истории сканирования: \(error)")
        }
    }

    func saveScan(timestamp: Date, deviceName: String) {
        let newScan = ScanHistory(context: context)
        newScan.id = UUID()
        newScan.timestamp = timestamp
        newScan.deviceName = deviceName

        do {
            try context.save()
            fetchScanHistory()
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }

    func applyFilter() {
        filteredHistory = scanHistory.filter { entry in
            let matchesText = filterText.isEmpty || entry.deviceName.lowercased().contains(filterText.lowercased())
            let matchesDate = filterDate == nil || Calendar.current.isDate(entry.timestamp, inSameDayAs: filterDate!)
            return matchesText && matchesDate
        }
    }
}

struct ScanHistoryModel: Identifiable {
    let id: UUID
    let timestamp: Date
    let deviceName: String
}
