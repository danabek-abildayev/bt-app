//
//  BluetoothView.swift
//  BTproject
//
//  Created by Danabek Abildayev on 23.12.2024.
//

import CoreData
import SwiftUI

struct BluetoothView: View {
    @StateObject private var viewModel: BluetoothViewModel
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: BluetoothViewModel(context: context))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                List(viewModel.devices) { device in
                    VStack(alignment: .leading) {
                        Text(device.name).font(.headline)
                        Text("UUID: \(device.uuid)").font(.subheadline)
                        Text("RSSI: \(device.rssi)").font(.subheadline)
                        Text("Status: \(device.status.rawValue)").font(.caption)
                            .foregroundColor(device.status == .connected ? .green : .gray)
                    }
                    .onTapGesture {
                        if device.status == .disconnected {
                            viewModel.connectToDevice(uuid: device.uuid)
                        }
                    }
                }
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(
                        title: Text("Connection fail"),
                        message: Text(viewModel.alertText),
                        dismissButton: .default(Text("OK"))
                    )
                }
                
                if viewModel.isBluetoothOn {
                    Text("Bluetooth is on").foregroundStyle(.green).font(.title3)
                } else {
                    Text("Bluetooth is off").foregroundStyle(.red).font(.title3)
                }
                
                Button(viewModel.isScanning ? "Stop Scanning" : "Start Scanning") {
                    viewModel.isScanning ? viewModel.stopScanning() : viewModel.startScanning()
                }
                .padding()
                .background(viewModel.isBluetoothOn ? .blue : .gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(!viewModel.isBluetoothOn)
            }
            .padding(.bottom)
            .navigationTitle("Bluetooth Devices")
        }
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
    return BluetoothView(context: context)
}
