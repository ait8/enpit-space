//
//  CentralManager.swift
//  enpit-space
//
//  Created by Kengo Yokoyama on 2015/07/17.
//  Copyright (c) 2015年 Kengo Yokoyama. All rights reserved.
//


import CoreBluetooth

class CentralManager: CBCentralManager, CBCentralManagerDelegate {
    private var nexturnObjectArray = [NexturnObject]()
    
    override init(delegate: CBCentralManagerDelegate!, queue: dispatch_queue_t!, options: [NSObject : AnyObject]!) {
        super.init(delegate: delegate, queue: queue, options: options)
        self.delegate = self
    }
    
    // MARK: - CBCentralManager Delegate Method
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        switch central.state {
        case .PoweredOn:
            let options = ["CBCentralManagerScanOptionAllowDuplicatesKey" : true]
            scanForPeripheralsWithServices(nil, options: options)
        default:
            break
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        if let name = peripheral.name {
            switch name {
            case NexturnObject.Property.kName!:
                let nexturnObject = NexturnObject()
                peripheral.delegate = nexturnObject
                nexturnObject.peripheral = peripheral
                connectPeripheral(nexturnObject.peripheral, options: nil)
                nexturnObjectArray.append(nexturnObject)
            default:
                break
            }
        }
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        if let name = peripheral.name {
            switch name {
            case NexturnObject.Property.kName!:
                let UUID = CBUUID(string: NexturnObject.Property.kLEDServiceUUID)
                nexturnObjectArray.last?.peripheral?.discoverServices([UUID])
            default:
                break
            }
        }
    }
    
    func play() {
        for nexturnObject in nexturnObjectArray {
            nexturnObject.play()
        }
    }
    
    func stop() {
        for nexturnObject in nexturnObjectArray {
            nexturnObject.stop()
        }
    }
    
    func reconnectPeripheral() {
        for nexturnObject in nexturnObjectArray {
            if nexturnObject.peripheral?.state != CBPeripheralState.Connected {
                connectPeripheral(nexturnObject.peripheral, options: nil)
            }
        }
    }
}