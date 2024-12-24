//
//  BluetoothService.swift
//  BTproject
//
//  Created by Danabek Abildayev on 23.12.2024.
//

import Foundation
import CoreBluetooth

class BluetoothService: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!
    
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var scanResults: [(CBPeripheral, NSNumber)] = []
    @Published var isBluetoothOn: Bool = false
    @Published var statusUpdates: (uuid: String, status: DeviceStatus)?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        discoveredPeripherals.removeAll()
        scanResults.removeAll()
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func stopScanning() {
        centralManager.stopScan()
    }
    
    func getPeripheral(by uuid: String) -> CBPeripheral? {
        return discoveredPeripherals.first(where: { $0.identifier.uuidString == uuid })
    }

    func connect(to peripheral: CBPeripheral) {
        statusUpdates = (uuid: peripheral.identifier.uuidString, status: .connecting)
        centralManager.connect(peripheral, options: nil)
    }
}

extension BluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isBluetoothOn = central.state == .poweredOn
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
            scanResults.append((peripheral, RSSI))
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral)")
        statusUpdates = (uuid: peripheral.identifier.uuidString, status: .connected)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Error occrued while connecting to \(peripheral): \(error?.localizedDescription ?? "unknown error")")
        statusUpdates = (uuid: peripheral.identifier.uuidString, status: .disconnected)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("\(peripheral) disconnected.")
        statusUpdates = (uuid: peripheral.identifier.uuidString, status: .disconnected)
    }
}
