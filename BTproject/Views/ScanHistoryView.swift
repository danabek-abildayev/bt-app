//
//  ScanHistoryView.swift
//  BTproject
//
//  Created by Danabek Abildayev on 23.12.2024.
//

import SwiftUI
import CoreData

struct ScanHistoryView: View {
    @StateObject private var viewModel: ScanHistoryViewModel
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: ScanHistoryViewModel(context: context))
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("Filter by name", text: $viewModel.filterText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                DatePicker("", selection: Binding(
                    get: { viewModel.filterDate ?? Date() },
                    set: { viewModel.filterDate = $0 }
                ), displayedComponents: .date)
                .labelsHidden()
                .padding()
            }
            
            List(viewModel.filteredHistory) { entry in
                VStack(alignment: .leading) {
                    Text(entry.deviceName)
                        .font(.headline)
                    Text("\(entry.timestamp, formatter: dateFormatter)")
                        .font(.subheadline)
                }
            }
            
            Button("Clear filtering") {
                viewModel.clearFilter()
            }
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .onAppear {
            viewModel.fetchScanHistory()
        }
        .padding(.bottom)
        .navigationTitle("Scan history")
        .onChange(of: viewModel.filterText) { _ in viewModel.applySSIDFilter() }
        .onChange(of: viewModel.filterDate) { _ in viewModel.applyDateFilter() }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    return ScanHistoryView(context: context)
}
