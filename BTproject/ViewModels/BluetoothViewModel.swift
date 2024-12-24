//
//  BluetoothViewModel.swift
//  BTproject
//
//  Created by Danabek Abildayev on 23.12.2024.
//

import CoreData
import SwiftUI
import CoreBluetooth
import Combine
import NetworkExtension
import CoreLocation

class BluetoothViewModel: ObservableObject {
    @Published var devices: [BluetoothDeviceModel] = []
    @Published var isScanning = false
    @Published var bluetoothService = BluetoothService()
    @Published var isBluetoothOn = false
    @Published var showAlert = false
    @Published var alertText = ""
    
    private let historyViewModel: ScanHistoryViewModel
    private let context: NSManagedObjectContext
    private var cancellables: Set<AnyCancellable> = []
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.historyViewModel = ScanHistoryViewModel(context: context)
        
        bluetoothService.$scanResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.handleScanResults(results)
            }
            .store(in: &cancellables)
        
        bluetoothService.$isBluetoothOn
            .receive(on: DispatchQueue.main)
            .assign(to: &$isBluetoothOn)
        
        bluetoothService.$statusUpdates
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (uuid, status) in
                self?.updateDeviceStatus(uuid: uuid, status: status)
            }
            .store(in: &cancellables)
    }
    
    func startScanning() {
        guard isBluetoothOn else { return }
        isScanning = true
        
        let timestamp = Date()
        let sampleDeviceName = "Sample Device"
        historyViewModel.saveScan(timestamp: timestamp, deviceName: sampleDeviceName)
        
        bluetoothService.startScanning()
    }
    
    func stopScanning() {
        isScanning = false
        bluetoothService.stopScanning()
    }
    
    func handleScanResults(_ results: [(CBPeripheral, NSNumber)]) {
        for (peripheral, rssi) in results {
            let name = peripheral.name ?? "Unknown"
            let uuid = peripheral.identifier.uuidString
            
            let request = BluetoothDeviceCDM.fetchRequest()
            request.predicate = NSPredicate(format: "uuid == %@", uuid)
            
            if let existingDevice = try? context.fetch(request).first {
                existingDevice.rssi = Int64(truncating: rssi)
            } else {
                let newDevice = BluetoothDeviceCDM(context: context)
                newDevice.name = name
                newDevice.uuid = uuid
                newDevice.rssi = Int64(truncating: rssi)
            }
            
            try? context.save()
        }
        showScannedDevices(results)
    }
    
    func showScannedDevices(_ results: [(per: CBPeripheral, rssi: NSNumber)]) {
        devices = results.map { BluetoothDeviceModel(name: $0.per.name ?? "Unknown", uuid: $0.per.identifier.uuidString, rssi: Int(truncating: $0.rssi), status: .disconnected)
        }
    }
    
    //MARK: connecting to BT device
    private func updateDevices(_ results: [(CBPeripheral, NSNumber)]) {
        for (peripheral, rssi) in results {
            let uuid = peripheral.identifier.uuidString
            if !devices.contains(where: { $0.uuid == uuid }) {
                devices.append(
                    BluetoothDeviceModel(
                        name: peripheral.name ?? "Unknown",
                        uuid: uuid,
                        rssi: rssi.intValue,
                        status: .disconnected
                    )
                )
            }
        }
    }
    
    private func updateDeviceStatus(uuid: String, status: DeviceStatus) {
        if let index = devices.firstIndex(where: { $0.uuid == uuid }) {
            devices[index].status = status
        }
    }
    
    func connectToDevice(uuid: String) {
        guard let peripheral = bluetoothService.getPeripheral(by: uuid) else {
            showAlert = true
            alertText = "Device not found. Please start scan again"
            return
        }
        bluetoothService.connect(to: peripheral)
    }
    
    //MARK: wifi ssid
    //    func getWIFISSID() {
    //        NEHotspotNetwork.fetchCurrent(completionHandler: { [weak self] (network) in
    //            if let unwrappedNetwork = network {
    //                let networkSSID = unwrappedNetwork.ssid
    //                print("Network: \(networkSSID)")
    //                self?.saveScanInfo(networkSSID)
    //            } else {
    //                print("No available network")
    //            }
    //        })
    //    }
    //
    //    private func saveScanInfo(_ ssid: String) {
    //        let timestamp = Date()
    //        let networkSSID = ssid
    //        historyViewModel.saveScan(timestamp: timestamp, deviceName: networkSSID)
    //    }
    
}

struct BluetoothDeviceModel: Identifiable {
    let id = UUID()
    let name: String
    let uuid: String
    let rssi: Int
    var status: DeviceStatus
}

enum DeviceStatus: String {
    case disconnected
    case connecting
    case connected
}
