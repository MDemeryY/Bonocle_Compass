//
//  Compass+BLE.swift
//  Bonocle_Compass
//
//  Created by Mahmoud ELDemery on 01/11/2021.
//

import Foundation
import CoreBluetooth
import UIKit
import BonocleKit

extension CompassController: BonocleDelegate {
    func deviceDidDisconnect(peripheral: CBPeripheral) {
        self.peripheral = nil
    }
    
    func deviceDidConnect(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        
    }
    
    func foundDevices(peripherals: [CBPeripheral]) {
    }
    
    
    func buttonEvent(peripheral: CBPeripheral, button: Buttons, event: ButtonEvents) {
        self.peripheral = peripheral
        switch event {
        case .singleClick:
            switch button {
            case.middle:
                if currentDirection != nil {
                    updateBonocle(brailleChar: currentDirection ?? "")
                }
            default: break
            }
            
        case .doubleClick:
            switch button {
            case.middle:
                if currentAngle != nil {
                    updateBonocle(brailleChar: currentAngle ?? "")
                }
            default: break
            }
        default:
            break
        }
    }
    
    func updateBonocle(brailleChar:String){
        if (self.peripheral != nil){
            if UserPrefrences.shared.isVibrationEnabled {
                if self.peripheral != nil {
                    BonocleCommunicationHelper.shared.vibrate(peripheral: self.peripheral!, hapticMotor: .both, with: .positive)
                }
            }
    
            BonocleCommunicationHelper.shared.autoScrollText(peripheral: self.peripheral!, text: brailleChar, loop: true)
        }
    }
}
