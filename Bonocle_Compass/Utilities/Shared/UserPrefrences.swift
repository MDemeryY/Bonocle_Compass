//
//  UserPrefrences.swift
//  Bonocle_Spelling
//
//  Created by Mahmoud ELDemery on 21/06/2021.
//

import Foundation

class UserPrefrences:NSObject,NSCoding {
    
    var englishLanguageType:String = "en-US"
    var brailleCode:String = "unicode.dis,en-ueb-g1.ctb"
    var brailleAndAudio:String?
    var isAudioEnabled:Bool = true
    var isVibrationEnabled:Bool = true
//    var settingList = [settingObject]()
    var movingWithEmptyCellsMode:Bool = true

    
    private override init(){}
    
    static var shared = UserPrefrences()
    
    static func save(){
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: shared)
        UserDefaults.standard.set(encodedData, forKey: "UserPrefrences")
        UserDefaults.standard.synchronize()
    }
    
    static func restore() -> UserPrefrences {
        if let decodedData  = UserDefaults.standard.object(forKey: "UserPrefrences") as? Data {
            if let restoredUser = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as? UserPrefrences{
                shared = restoredUser
                return shared
            }
        }
        return shared
    }
    
    
    static func delete() {
        shared.englishLanguageType = "en-US"
        shared.brailleCode = "unicode.dis,en-ueb-g1.ctb"
        shared.brailleAndAudio = nil
        shared.isAudioEnabled = true
        shared.isVibrationEnabled = true
        shared.movingWithEmptyCellsMode = true

        
//        shared.settingList = []
        UserDefaults.standard.set(nil, forKey: "UserPrefrences")
    }
    
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(englishLanguageType, forKey: "englishLanguageType")
        aCoder.encode(brailleCode, forKey: "brailleCode")
        aCoder.encode(brailleAndAudio, forKey: "brailleAndAudio")
        aCoder.encode(isAudioEnabled, forKey: "isAudioEnabled")
        aCoder.encode(isVibrationEnabled, forKey: "isVibrationEnabled")
        aCoder.encode(movingWithEmptyCellsMode, forKey: "movingWithEmptyCellsMode")

        
//        aCoder.encode(settingList, forKey: "settingList")

    }
    
    required init?(coder aDecoder: NSCoder) {
        self.englishLanguageType = aDecoder.decodeObject(forKey: "englishLanguageType") as! String 
        self.brailleCode = aDecoder.decodeObject(forKey: "brailleCode") as! String
        self.brailleAndAudio = aDecoder.decodeObject(forKey: "brailleAndAudio") as? String
        self.isAudioEnabled = aDecoder.decodeBool(forKey: "isAudioEnabled")
        self.movingWithEmptyCellsMode = aDecoder.decodeBool(forKey: "movingWithEmptyCellsMode")
        self.isVibrationEnabled = aDecoder.decodeBool(forKey: "isVibrationEnabled")
//        self.settingList = aDecoder.decodeObject(forKey: "settingList") as! [settingObject]

    }
}
