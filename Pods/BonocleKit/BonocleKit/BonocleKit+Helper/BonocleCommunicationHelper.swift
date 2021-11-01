//
//  BonocleCommunicationHelper.swift
//  BonocleKit
//
//  Created by Andrew on 9/13/21.
//

import Foundation
import CoreBluetooth
import Speech
import UIKit
public class BonocleCommunicationHelper:  NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    public static let shared = BonocleCommunicationHelper()
    public var connectedPeripheral : CBPeripheral?
    //Data
    var centralManager : CBCentralManager!
    var RSSIs = [NSNumber]()
    var peripherals: [CBPeripheral] = []
    var connectedPeripherals: [CBPeripheral] = []
    var timer = Timer()
    let speechSynthesizer = AVSpeechSynthesizer()
    let audioSession = AVAudioSession.sharedInstance()
    
    var subscribeToIMU = false
    var subscribeToOptical = false
    
    public var autoScrollSpeed = 0.7
    var autoSrollText = ""
    var autoSrollLoop = false
    var autoSrollIndex = 0
    
    public var xSpacing = 200
    public var ySpacing = 200
    
    var IMUConfig = 3
    
    public weak var deviceDelegate: BonocleDelegate?
    
    private override init(){
        /*Our key player in this app will be our CBCentralManager. CBCentralManager objects are used to manage discovered or connected remote peripheral devices (represented by CBPeripheral objects), including scanning for, discovering, and connecting to advertising peripherals.
         */
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(applicationWillBecomeInActive),
                                               name: UIApplication.willResignActiveNotification,
            object: nil)
    }
    
    @objc func applicationDidBecomeActive() {
        // handle event
        UIApplication.shared.isIdleTimerDisabled = true
        print("APP OPENED")
        setupPerAppConfig()
    }
    
    @objc func applicationWillBecomeInActive() {
        // handle event
        print("APP CLOSED")
    }
    
    func setupPerAppConfig(){
//        if BLE_Characteristic_IMU_XYZ != nil && connectedPeripheral != nil {
//            connectedPeripheral!.setNotifyValue(self.subscribeToIMU, for: BLE_Characteristic_IMU_XYZ!)
//        }
//
//        if BLE_Characteristic_Optical_XY != nil && connectedPeripheral != nil {
//            connectedPeripheral!.setNotifyValue(self.subscribeToOptical, for: BLE_Characteristic_Optical_XY!)
//        }
        
        updateOpticalSpacing(peripheral: connectedPeripheral, x_spacing: self.xSpacing, y_spacing: self.ySpacing)
        updateIMUConfig(peripheral: connectedPeripheral, res: self.IMUConfig)
    }
    
    
    
    // MARK: - Bonocle Communication
    /*Okay, now that we have our CBCentalManager up and running, it's time to start searching for devices. You can do this by calling the "scanForPeripherals" method.*/
    public func startScan() {
        peripherals = []
        
        let connectedDevices = centralManager?.retrieveConnectedPeripherals(withServices: [AdvertisedBLEService])
        
        for device in connectedDevices! {
            if device.name == "Bonocle_V2" {
                print("Already connected")
                self.peripherals.append(device)
                centralManager?.stopScan()
                connectToDevice(device: device)
                device.delegate = self
                return
            }
        }
        
        print("HELPER -  Now Scanning...")
        showLoader()
        centralManager?.scanForPeripherals(withServices: [AdvertisedBLEService] , options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
    }
    
    /*We also need to stop scanning at some point so we'll also create a function that calls "stopScan"*/
    @objc func cancelScan() {
        self.centralManager?.stopScan()
        print("HELPER -  Scan Stopped")
        print("HELPER -  Number of Peripherals Found: \(peripherals.count)")
    }
    
    //-Connection
    //Peripheral Connections: Connecting, Connected, Disconnected
    func connectToDevice (device : CBPeripheral) {
        centralManager?.connect(device, options: nil)
    }
    
    //Peripheral Connections: Connecting, Connected, Disconnected
    func connectToDevices (devices : [CBPeripheral]) {
        for device in devices {
            centralManager?.connect(device, options: nil)
        }
    }
    
    //-Terminate all Peripheral Connection
    /*
     Call this when things either go wrong, or you're done with the connection.
     This cancels any subscriptions if there are any, or straight disconnects if not.
     (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
     */
    public func disconnectFromDevice (device : CBPeripheral) {
        // We have a connection to the device but we are not subscribed to the Transfer Characteristic for some reason.
        // Therefore, we will just disconnect from the peripheral
        centralManager?.cancelPeripheralConnection(device)
        startScan()
    }
    
    public func disconnectAllConnection() {
//        centralManager.cancelPeripheralConnection(blePeripheral!)
    }
    
    
    
    // MARK: - CBCentralManagerDelegate
    /*
     Invoked when a connection is successfully created with a peripheral.
     This method is invoked when a call to connect(_:options:) is successful. You typically implement this method to set the peripheral’s delegate and to discover its services.
     */
    //-Connected
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("*****************************")
        print("Connection complete")
        print("Peripheral info: \(String(describing: peripheral))")
        
        //Stop Scan- We don't need to scan once we've connected to a peripheral. We got what we came for.
        centralManager?.stopScan()
        print("HELPER -  Scan Stopped")
        
        //Erase data that we might have
//        data.length = 0
        
        //Discovery callback
        peripheral.delegate = self
        //Only look for services that matches transmit uuid
        peripheral.discoverServices([kBLE_Service_Braille, kBLE_Service_IMU,  kBLE_Service_Buttons, kBLE_Service_Haptics, kBLE_Service_Optical])
        connectedPeripheral = peripheral
        if(self.deviceDelegate != nil){
            self.deviceDelegate!.deviceDidConnect(peripheral: peripheral)
        }
    }
    
    /*
     Invoked when the central manager fails to create a connection with a peripheral.
     */
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        startScan()
        if error != nil {
            print("HELPER -  Failed to connect to peripheral")
            return
        }
    }
    
    
    /*
     Invoked when the central manager’s state is updated.
     This is where we kick off the scan if Bluetooth is turned on.
     */
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            // We will just handle it the easy way here: if Bluetooth is on, proceed...start scan!
            print("HELPER -  Bluetooth Enabled")
            startScan()
            
        } else {
            //If Bluetooth is off, display a UI alert message saying "Bluetooth is not enable" and "Make sure that your bluetooth is turned on"
            print("HELPER -  Bluetooth Disabled- Make sure your Bluetooth is turned on")
            
        }
    }
    
    /*
     Called when the central manager discovers a peripheral while scanning. Also, once peripheral is connected, cancel scanning.
     */
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if ((advertisementData["kCBAdvDataLocalName"]) != nil){
            if(advertisementData["kCBAdvDataLocalName"] as! String == "Bonocle"){
                if(!self.peripherals.contains(peripheral)){
                    print("HELPER -  Found Device: "+(peripheral.name ?? "NaN"))
                    print("Peripheral Local name: \(String(describing: advertisementData["kCBAdvDataLocalName"]))")
                    
                    self.peripherals.append(peripheral)
                    self.RSSIs.append(RSSI)
                }
                centralManager?.stopScan()
                connectToDevice(device: peripheral)
                peripheral.delegate = self
            }
        }
        
        if(self.deviceDelegate != nil){
            self.deviceDelegate!.foundDevices(peripherals: self.peripherals)
        }
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        print("HELPER -  Disconnected")
        bonocleConnectionState(peripheral, state: "Bonocle Disconnected")
        startScan()
        if(self.deviceDelegate != nil){
            self.deviceDelegate!.deviceDidDisconnect(peripheral: peripheral)
        }
    }
    
    func restoreCentralManager() {
        //Restores Central Manager delegate if something went wrong
        centralManager?.delegate = self
    }
    
    
    // MARK: - CBPeripheralDelegate
    
    /*
     Invoked when you discover the peripheral’s available services.
     This method is invoked when your app calls the discoverServices(_:) method. If the services of the peripheral are successfully discovered, you can access them through the peripheral’s services property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
     */
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("*******************************************************")
        
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        //We need to discover the all characteristic
        for service in services {
            
            switch service.uuid.uuidString {
            case kBLE_Service_Buttons.uuidString:
                BLE_Service_Buttons = service
                peripheral.discoverCharacteristics(buttonsServiceCharacteristics, for: service)
            case kBLE_Service_Braille.uuidString:
                BLE_Service_Braille = service
                peripheral.discoverCharacteristics(brailleServiceCharacteristics, for: service)
            case kBLE_Service_IMU.uuidString:
                BLE_Service_IMU = service
                peripheral.discoverCharacteristics(IMUServiceCharacteristics, for: service)
            case kBLE_Service_Optical.uuidString:
                BLE_Service_Optical = service
                peripheral.discoverCharacteristics(opticalServiceCharacteristics, for: service)
            case kBLE_Service_Haptics.uuidString:
                BLE_Service_Haptics = service
                peripheral.discoverCharacteristics(hapticsServiceCharacteristics, for: service)
            
            default:
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
        print("Discovered Services: \(services)")
    }
    
    /*
     Invoked when you discover the characteristics of a specified service.
     This method is invoked when your app calls the discoverCharacteristics(_:for:) method. If the characteristics of the specified service are successfully discovered, you can access them through the service's characteristics property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
     */
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("*******************************************************")
        
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        print("Found \(characteristics.count) characteristics! in Service \(service.uuid)")
        
        for characteristic in characteristics {
            //looks for the right characteristic
            
            if      (service.hasUUID(uuid: kBLE_Service_Optical) && subscribeToOptical)
                ||  (service.hasUUID(uuid: kBLE_Service_IMU) && subscribeToIMU)
                ||  service.hasUUID(uuid: kBLE_Service_Buttons)
                ||  characteristic.hasUUID(uuid: kBLE_Characteristic_Battery)
                ||  characteristic.hasUUID(uuid: kBLE_Characteristic_Auto_Scroll)
            {
                
                //Once found, subscribe to the this particular characteristic...
                peripheral.setNotifyValue(true, for: characteristic)
                // We can return after calling CBPeripheral.setNotifyValue because CBPeripheralDelegate's
                // didUpdateNotificationStateForCharacteristic method will be called automatically
//                peripheral.readValue(for: characteristic)
                
//                peripheral.readValue(for: characteristic)
                print("Subscribed to characteristic: \(characteristic.uuid)")
            }
            
            if characteristic.hasUUID(uuid: kBLE_Characteristic_Haptics) {
                BLE_Characteristic_Haptics = characteristic
                
                //*********cancelScan()******
                print("BLE_Characteristic_Haptics: \(characteristic.uuid)")
            }
            
            if characteristic.hasUUID(uuid: kBLE_Characteristic_Buzzer) {
                BLE_Characteristic_Buzzer = characteristic
                
                //*********cancelScan()******
                print("BLE_Characteristic_Buzzer: \(characteristic.uuid)")
            }
            
            if characteristic.hasUUID(uuid: kBLE_Characteristic_Braille) {
                BLE_Characteristic_Braille = characteristic
                
                //*********cancelScan()******
                print("BLE_Characteristic_Braille: \(characteristic.uuid)")
            }
            
            if characteristic.hasUUID(uuid: kBLE_Characteristic_Braille) {
                BLE_Characteristic_Braille = characteristic
                
                //*********cancelScan()******
                print("BLE_Characteristic_Braille: \(characteristic.uuid)")
            }
            
            if characteristic.hasUUID(uuid: kBLE_Characteristic_Optical_Config) {
                BLE_Characteristic_Optical_Config = characteristic
                updateOpticalSpacing(peripheral: peripheral, x_spacing: self.xSpacing, y_spacing: self.ySpacing)
                //*********cancelScan()******
                print("BLE_Characteristic_Optical_Config: \(characteristic.uuid)")
            }
            
            if characteristic.hasUUID(uuid: kBLE_Characteristic_Auto_Scroll) {
                BLE_Characteristic_Auto_Scroll = characteristic
//                updateAutoScrollSpeed(peripheral: peripheral, speed: self.autoScrollSpeed)
                //*********cancelScan()******
                print("BLE_Characteristic_Auto_Scroll: \(characteristic.uuid)")
            }
            
            if characteristic.hasUUID(uuid: kBLE_Characteristic_IMU_Config) {
                BLE_Characteristic_IMU_Config = characteristic
                updateIMUConfig(peripheral: peripheral, res: self.IMUConfig)
                //*********cancelScan()******
                print("BLE_Characteristic_IMU_Config: \(characteristic.uuid)")
            }
            
            if characteristic.hasUUID(uuid: kBLE_Characteristic_Device_Config) {
                BLE_Characteristic_Device_Config = characteristic
                
                //*********cancelScan()******
                print("BLE_Characteristic_Device_Config: \(characteristic.uuid)")
            }
            
            // battery characteristic
            if characteristic.hasUUID(uuid: kBLE_Characteristic_Battery){
                BLE_Characteristic_Battery = characteristic
                
                peripheral.readValue(for: characteristic)
                print("BLE_Characteristic_Battery \(characteristic.uuid)")
            }
            
        }
    }
    
    // Getting Values From Characteristic
    
    /*After you've found a characteristic of a service that you are interested in, you can read the characteristic's value by calling the peripheral "readValueForCharacteristic" method within the "didDiscoverCharacteristicsFor service" delegate.
     */
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
//        print("Characteristic \(characteristic.uuid.uuidString) value changed to: \(characteristic.value!.hexEncodedString())")
        
//        if(self.deviceDelegate == nil){
//            print("NO DELEGATE")
//            return
//        }
        
        switch characteristic.uuid.uuidString {
        case kBLE_Characteristic_Buttons.uuidString:
            handleButtonEvent(peripheral: peripheral, value: characteristic.value)
            return
        case kBLE_Characteristic_Optical_XY.uuidString:
            handleOpticalEvent(peripheral: peripheral, value: characteristic.value)
            return
        case kBLE_Characteristic_IMU_XYZ.uuidString:
            handleIMUEvent(peripheral: peripheral, value: characteristic.value)
            return
        case kBLE_Characteristic_Auto_Scroll.uuidString:
            handleAutoScrollSpeedUpdated(peripheral: peripheral, value: characteristic.value)
            return
        case kBLE_Characteristic_Battery.uuidString:
            handleBatteryEvent(peripheral: peripheral, value: characteristic.value)
            return
        default:
            return
        }
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")
        
        if error != nil {
            print("\(error.debugDescription)")
            return
        }
        if ((characteristic.descriptors) != nil) {
            
//            for x in characteristic.descriptors!{
//                let descript = x as CBDescriptor?
////                print("function name: DidDiscoverDescriptorForChar \(String(describing: descript?.description))")
////                print("Rx Value \(String(describing: rxCharacteristic?.value))")
////                print("Tx Value \(String(describing: txCharacteristic?.value))")
//            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")
        
        if (error != nil) {
            print("Error changing notification state:\(String(describing: error?.localizedDescription))")
            
        } else {
            print("Characteristic's value subscribed")
        }
        
        if (characteristic.isNotifying) {
            print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
            if characteristic.uuid.uuidString == "C006" {
                updateBraille(peripheral: peripheral, pins: brailleMetecMap["⣉"] ?? 0x00)
                vibrate(peripheral: peripheral, hapticMotor: .both, with: .positive)
            }
            
            if characteristic.uuid.uuidString == "C001" {
                hideLoader()
                bonocleConnectionState(peripheral, state: "Bonocle Connected")
            }
            
            if characteristic.uuid.uuidString == "A002" {
                self.deviceDelegate?.deviceDidUpdate(peripheral: peripheral)
            }
        }
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
//        print("HELPER -  Message sent")
//        print(characteristic.uuid)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
        print("HELPER -  Succeeded!")
    }
    
    //Nudge 0xF0
    //Harsh 0xFF
    
    private func handleButtonEvent(peripheral: CBPeripheral, value: Data?){
//        self.deviceDelegate!.buttonEvent(peripheral: peripheral, button: .left, event: ButtonEvents(rawValue: value)!)
        print("Buttons Changed")
        let byte = value![0]
        let string = byte.bin
//        print(byte.bin)
        let buttonNumberBinary = string.suffix(3)
        
        var button = Buttons.middle
        var event = ButtonEvents.singleClick
        
        if let buttonNumber = Int(buttonNumberBinary, radix: 2) {
            switch buttonNumber {
            case 0:
                print("Left Button")
                button = .left
            case 1:
                print("Right Button")
                button = .right
            case 2:
                print("Middle Button")
                button = .middle
            case 3:
                print("Bottom Button")
                button = .bottom
            case 4:
                print("Left Side Button")
                button = .sideLeft
            case 5:
                print("Right Side Button")
                button = .sideRight
            default:
                print(buttonNumber)
            }
        }
        
        if string[4] == "1" {
            //released
            print("released")
            event = .released
        }
        
        if string[3] == "1" {
            //pressed
            print("Single Click")
            event = .singleClick
        }
        
        if string[2] == "1" {
            //Long
            print("Hold")
            event = .hold
        }
        
        if string[1] == "1" {
            //Double
            print("Double")
            event = .doubleClick
        }
        
        if(self.deviceDelegate != nil){
            self.deviceDelegate!.buttonEvent(peripheral: peripheral, button: button, event: event)
        }
    }
    
    private func handleOpticalEvent(peripheral: CBPeripheral, value: Data?){
        
        print("Optical Changed")
        print(value!.hexEncodedString())
        
        let byte0 = Int16(value![0])
        let byte1 = Int16(value![1])
        let byte2 = Int16(value![2])
        let byte3 = Int16(value![3])
        
        let x: Int16 = ((byte1 << 8) | byte0)
        let y: Int16 = ((byte3 << 8) | byte2)
    
        let deltaX = Int(x)/(self.xSpacing*10)
        let deltaY = Int(y)/(self.ySpacing*10)
        
        print(x)
        print(y)
        
        print("Delata X : ")
        print(deltaX)
        
        print("Delata Y : ")
        print(deltaY)
        
        if(self.deviceDelegate != nil){
            self.deviceDelegate!.opticalEvent(peripheral: peripheral, x: Int(x), y: Int(y))
            self.deviceDelegate!.opticalEventSteps(peripheral: peripheral, x: deltaX, y: deltaY)
        }

    }
    
    private func handleIMUEvent(peripheral: CBPeripheral, value: Data?){
        print("IMU Changed")
        print(value!.hexEncodedString())
        
        let byte0 = Int16(value![0])
        let byte1 = Int16(value![1])
        let byte2 = Int16(value![2])
        let byte3 = Int16(value![3])
        let byte4 = Int16(value![4])
        let byte5 = Int16(value![5])
        
        let x: Int16 = ((byte1 << 8) | byte0)
        let y: Int16 = ((byte3 << 8) | byte2)
        let z: Int16 = ((byte5 << 8) | byte4)
        
        print(x)
        print(y)
        print(z)
        
        if(self.deviceDelegate != nil){
            self.deviceDelegate!.imuEvent(peripheral: peripheral, X: Int(x), Y: Int(y), Z: Int(z))
        }
    }
    
    private func handleBatteryEvent(peripheral: CBPeripheral, value: Data?){
        print("Battery Changed")
        print(value!.hexEncodedString())
        
        if(self.deviceDelegate != nil){
            if value!.hexEncodedString() == "0x08" {
                self.deviceDelegate!.batteryState(peripheral: peripheral, value: -1, charging: true)
            }else{
                self.deviceDelegate!.batteryState(peripheral: peripheral, value: Int(value![0]), charging: false)
            }
        }
    
    }
    
    
    private func handleAutoScrollSpeedUpdated(peripheral: CBPeripheral, value: Data?){
        if value == nil {
            return
        }
        
        print("Auto Scroll Speed Updated")
        print(value!.hexEncodedString())
        
        
        print(autoScrollSpeed)
    }
    
    //TRIGGERS
    public func vibrate(peripheral: CBPeripheral, hapticMotor: HapticMotors, with pattern: HapticPatterns){
        if BLE_Characteristic_Haptics != nil{
            var data: [UInt8] = [0x01, 0xF0, 0x00, 0x01]
            let enableBytes = NSData(bytes: &data, length:data.count)
            
            peripheral.writeValue(enableBytes as Data, for: BLE_Characteristic_Haptics!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    public func vibrate(peripheral: CBPeripheral, hapticMotor: HapticMotors, with strenght: Int, for duration: Int, with pattern: HapticPatterns){
        if BLE_Characteristic_Haptics != nil{
            var data = [255, 255, 2, 3]
            let enableBytes = NSData(bytes: &data, length:data.count)
            
            switch hapticMotor {
            case .right:
                data[3] = 0x01
            case .left:
                data[3] = 0x02
            case .both:
                data[3] = 0x03
            }
            
            peripheral.writeValue(enableBytes as Data, for: BLE_Characteristic_Haptics!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    public func updateBraille(peripheral: CBPeripheral, letter: String){
        endTimer()
        if BLE_Characteristic_Braille != nil {
            var data = [brailleMetecMap[letter]]
            let enableBytes = NSData(bytes: &data, length:data.count)
            peripheral.writeValue(enableBytes as Data, for: BLE_Characteristic_Braille!, type: CBCharacteristicWriteType.withResponse)
        }
        
    }
    
    public func updateBraille(peripheral: CBPeripheral, pins: UInt){
        endTimer()
        if BLE_Characteristic_Braille != nil {
            var data = [pins]
            let enableBytes = NSData(bytes: &data, length:data.count)
            peripheral.writeValue(enableBytes as Data, for: BLE_Characteristic_Braille!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    
    public func sendBraile(peripheral: CBPeripheral?, letter: String){
        if BLE_Characteristic_Braille != nil && peripheral != nil {
            var data = [brailleMetecMap[letter]]
            let enableBytes = NSData(bytes: &data, length:data.count)
            peripheral!.writeValue(enableBytes as Data, for: BLE_Characteristic_Braille!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    public func updateOpticalSpacing(peripheral: CBPeripheral?, x_spacing: Int, y_spacing: Int){
        self.xSpacing = x_spacing
        self.ySpacing = y_spacing
        if BLE_Characteristic_Optical_Config != nil && peripheral != nil {
            var data = [x_spacing.toUInt8(), y_spacing.toUInt8()]
            let enableBytes = NSData(bytes: &data, length:data.count)
            peripheral!.writeValue(enableBytes as Data, for: BLE_Characteristic_Optical_Config!, type: CBCharacteristicWriteType.withResponse)
        }
    }

    
    public func updateAutoScrollSpeed(peripheral: CBPeripheral?, speed: Int){
        if BLE_Characteristic_Auto_Scroll != nil && peripheral != nil {
            var data = [speed.toUInt8()]
            let enableBytes = NSData(bytes: &data, length:data.count)
            peripheral!.writeValue(enableBytes as Data, for: BLE_Characteristic_Auto_Scroll!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    public func updateIMUConfig(peripheral: CBPeripheral?, res: Int){
        self.IMUConfig = res
        
        if BLE_Characteristic_IMU_Config != nil && peripheral != nil {
            var data = [res.toUInt8()]
            let enableBytes = NSData(bytes: &data, length:data.count)
            peripheral!.writeValue(enableBytes as Data, for: BLE_Characteristic_IMU_Config!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    private func getAutoScrollSpeed(peripheral: CBPeripheral){
        if BLE_Characteristic_Auto_Scroll != nil {
            peripheral.readValue(for: BLE_Characteristic_Auto_Scroll!)
        }
    }
    
    private func getBatteryStatus(peripheral: CBPeripheral){
        if BLE_Characteristic_Battery != nil {
            peripheral.readValue(for: BLE_Characteristic_Battery!)
        }
    }
    
    private func endTimer() {
        timer.invalidate()
    }
    
    private func updateTimer(peripheral: CBPeripheral?) {
        endTimer()
        activateAutoScrollTimer(peripheral: peripheral)
    }
    
    private func activateAutoScrollTimer(peripheral: CBPeripheral?){
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.autoScrollSpeed), target: self, selector: #selector(self.handleAutoScrollTimer(sender:)), userInfo: peripheral, repeats: true)
    }
    
    @objc func handleAutoScrollTimer(sender: Timer){
        
        let peripheral = (sender.userInfo as? CBPeripheral)
        
        
        if self.autoSrollLoop {
            self.autoSrollIndex = self.autoSrollIndex % self.autoSrollText.count
        }
        
        let letterIndex = self.autoSrollIndex
        
        if  peripheral != nil && peripheral?.state == .connected && self.autoSrollIndex < self.autoSrollText.count &&  self.autoSrollIndex >= 0{
            sendBraile(peripheral: peripheral!, letter: String(self.autoSrollText[letterIndex]))

        }
        self.autoSrollIndex = self.autoSrollIndex + 1
        //if tilt handle check IMU
        //Else call nextLetter
        
    }
    
    public func autoScrollText(peripheral: CBPeripheral?, text: String, loop: Bool, scrollSpeed: Double? = nil){
        endTimer()
        self.autoSrollText = text
        self.autoSrollLoop = loop
        self.autoSrollIndex = 0
        self.autoScrollSpeed = scrollSpeed ?? autoScrollSpeed
        if text.count > 1 {
            updateTimer(peripheral: peripheral)
        }else{
            sendBraile(peripheral: peripheral!, letter: text)
        }
    }
    
    public func stopAutoScroll(peripheral: CBPeripheral?){
        endTimer()
        sendBraile(peripheral: peripheral!, letter: " ")
    }
    
    public func setIMUSubscription(peripheral: CBPeripheral?, to: Bool){
        subscribeToIMU = to
        if BLE_Characteristic_IMU_XYZ != nil && peripheral != nil{
            peripheral!.setNotifyValue(to, for: BLE_Characteristic_IMU_XYZ!)
        }
    }
    
    public func setOpticalSubscription(peripheral: CBPeripheral?, to: Bool){
        subscribeToOptical = to
        if BLE_Characteristic_Optical_XY != nil && peripheral != nil{
            peripheral!.setNotifyValue(to, for: BLE_Characteristic_Optical_XY!)
        }
    }

    private func bonocleConnectionState(_ peripheral: CBPeripheral, state: String) {
        do{
            let _ = try audioSession.setCategory(.playback,options: .duckOthers)
        }catch{
            print(error)
        }
        DispatchQueue.main.async { [weak self] in
            self?.speechSynthesizer.stopSpeaking(at: .word)
            let sentence = state
            let speechUtterance = AVSpeechUtterance(string:sentence)
            speechUtterance.voice = AVSpeechSynthesisVoice(language:"en-US")
            speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
            self?.speechSynthesizer.speak(speechUtterance)
            self?.vibrate(peripheral: peripheral, hapticMotor: .both, with: .positive)
            self?.sendBraile(peripheral: peripheral, letter: " ")
        }
    }
    
    private func showLoader() {
        let alert = UIAlertController(title: "    Searching for Bonocle...", message: "", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 3, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            loadingIndicator.style = UIActivityIndicatorView.Style.medium
        } else {
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
        }
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
        
    private func showConnectingMsg(){
        let alert = UIAlertController(title: "Bonocle Connected", message: "" , preferredStyle: .alert)
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1){
            UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
        }
    }
        
    private func hideLoader() {
        UIApplication.topViewController()?.dismiss(animated: true, completion: {
            self.showConnectingMsg()
        })
    }
}
