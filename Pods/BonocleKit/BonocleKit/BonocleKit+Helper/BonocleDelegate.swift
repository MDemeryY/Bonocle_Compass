//
//  BonocleDelegate.swift
//  BonocleKit
//
//  Created by Andrew on 9/13/21.
//

import Foundation
import CoreBluetooth
public protocol BonocleDelegate: class {
    func deviceDidConnect(peripheral: CBPeripheral)
    func deviceDidDisconnect(peripheral: CBPeripheral)
    func deviceDidUpdate(peripheral: CBPeripheral)
    func foundDevices(peripherals : [CBPeripheral])
    func opticalEvent(peripheral: CBPeripheral, x: Int, y: Int)
    func opticalEventSteps(peripheral: CBPeripheral, x: Int, y: Int)
    func imuEvent(peripheral: CBPeripheral, X: Int, Y: Int, Z: Int)
    func imuEventStep(peripheral: CBPeripheral, X: Int, Y: Int, Z: Int)
    func buttonEvent(peripheral: CBPeripheral, button: Buttons, event: ButtonEvents)
    func batteryState(peripheral: CBPeripheral, value: Int, charging: Bool)
    func UpdateDelegate()
}

public extension BonocleDelegate {
    func deviceDidUpdate(peripheral: CBPeripheral){}
    func foundDevices(peripherals : [CBPeripheral]){}
    func opticalEvent(peripheral: CBPeripheral, x: Int, y: Int){}
    func opticalEventSteps(peripheral: CBPeripheral, x: Int, y: Int){}
    func imuEvent(peripheral: CBPeripheral, X: Int, Y: Int, Z: Int){}
    func imuEventStep(peripheral: CBPeripheral, X: Int, Y: Int, Z: Int){}
    func buttonEvent(peripheral: CBPeripheral, button: Buttons, event: ButtonEvents){}
    func batteryState(peripheral: CBPeripheral, value: Int, charging: Bool){}
    func UpdateDelegate(){}
}
