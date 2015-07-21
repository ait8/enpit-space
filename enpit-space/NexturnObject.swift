//
//  NexturnObject.swift
//  enpit-space
//
//  Created by Kengo Yokoyama on 2015/07/17.
//  Copyright (c) 2015年 Kengo Yokoyama. All rights reserved.
//

import CoreBluetooth

class NexturnObject: NSObject, CBPeripheralDelegate {
    enum Property {
        static var kName: String! = "Nexturn"
        static var kLEDServiceUUID: String! = "FFE0"
    }
    
    var peripheral: CBPeripheral?
    private var characteristicArray = [CBCharacteristic]()
    
    private var ledPattern = [ledButtonTag.Red,    ledButtonTag.Off,
                              ledButtonTag.Yellow, ledButtonTag.Off,
                              ledButtonTag.Green,  ledButtonTag.Off,
                              ledButtonTag.Cyan,   ledButtonTag.Off,
                              ledButtonTag.Blue,   ledButtonTag.Off,
                              ledButtonTag.Purple, ledButtonTag.Off]
    
    private var ledPatternIndex = 0
    
    private enum ledButtonTag: Int {
        case Red, Yellow, Green, Cyan, Blue, Purple, Off
        
        private var type: NSData {
            get {
                switch self {
                case .Red:
                    return createLedData(UInt32(0xFF000000))
                case .Yellow:
                    return createLedData(UInt32(0xFFFF0000))
                case .Green:
                    return createLedData(UInt32(0x00FF0000))
                case .Cyan:
                    return createLedData(UInt32(0x00FFFF00))
                case .Blue:
                    return createLedData(UInt32(0x0000FF00))
                case .Purple:
                    return createLedData(UInt32(0xFF00FF00))
                case .Off:
                    return createLedData(UInt32(0))
                }
            }
        }
        
        func createLedData(hexData: UInt32) -> NSData {
            let red   = UInt8((hexData & 0xFF000000) >> 24)
            let green = UInt8((hexData & 0x00FF0000) >> 16)
            let blue  = UInt8((hexData & 0x0000FF00) >> 8)
            let white = UInt8(hexData & 0x000000FF)
            var data  = [red, green, blue, white]
            
            return NSData(bytes: &data, length: 4)
        }
    }
    
    func play() {
        if peripheral?.state == CBPeripheralState.Connected {
            peripheral?.writeValue(ledPattern[ledPatternIndex].type, forCharacteristic: characteristicArray[4], type: .WithResponse)
            ledPatternIndex++
            if ledPatternIndex >= ledPattern.count {
                ledPatternIndex = 0
            }
        }
    }

    func stop() {
        if peripheral?.state == CBPeripheralState.Connected {
            peripheral?.writeValue(ledButtonTag.Off.type, forCharacteristic: characteristicArray[4], type: .WithResponse)
            ledPatternIndex = 0
        }
    }
    
    // MARK: - CBPeripheralDelegate
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        for service in peripheral.services {
            self.peripheral?.discoverCharacteristics(nil, forService: service as! CBService)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        for characteristic in service.characteristics {
            self.characteristicArray.append(characteristic as! CBCharacteristic)
        }
    }
}