//
//  LiblouisManager.swift
//  Bonocle_Spelling
//
//  Created by Mahmoud ELDemery on 24/06/2021.
//

import Foundation

class Liblouis{
    
    static func loadTable(){
        if let resourceUrl = Bundle.main.url(forResource: "as", withExtension: "tbl") {
            if FileManager.default.fileExists(atPath: resourceUrl.path) {
                let path = resourceUrl.path.replacingOccurrences(of: "/as.tbl", with: "")
                lou_setDataPath(path)
            }
        }
    }
    
    
    static func getArrayOfCharsByIndexes(english : String , braille : String , arrayOfIndexes : [Int32]) -> [String]{
        
        let dictionaryOfIndexesAndValueOfStrings = NSMutableDictionary()
        
        for (index,charIndex) in arrayOfIndexes.enumerated(){
            if dictionaryOfIndexesAndValueOfStrings[charIndex] != nil{
                let valueOfIndex = dictionaryOfIndexesAndValueOfStrings[charIndex] as! String
                dictionaryOfIndexesAndValueOfStrings[charIndex] = valueOfIndex + String((Array(english)[index]))
            }
            else
            {
                dictionaryOfIndexesAndValueOfStrings[charIndex] = String(Array(english)[index])
            }
        }
        
        let dictionaryOfIndexesAndValueSorted = dictionaryOfIndexesAndValueOfStrings.sorted{$1.key as! Int > $0.key as! Int} 
        let valuesArraySorted = Array(dictionaryOfIndexesAndValueSorted.map({ $0.value }))

        return valuesArraySorted as! [String]
        
    }
    
    static func translateToBraille(toBraille: String, tableUnicode: String ) -> String{
        let sourceString = toBraille.lowercased()
        var sourceUTF16 = Array(sourceString.utf16)
        var sourceLength = CInt(sourceUTF16.count)
        let maxBufferSize = 10000
        var destUTF16 = Array<UInt16>(repeating: 0, count: maxBufferSize)
        var destLength = CInt(destUTF16.count)
        lou_translateString(tableUnicode, &sourceUTF16, &sourceLength, &destUTF16, &destLength, nil, nil, 0)
//        let destString = String(utf16CodeUnits: destUTF16, count: Int(destLength))
        
        let destString = String(utf16CodeUnits: destUTF16, count: Int(destLength))
        
        let lastChar = String(destString[destString.index(before: destString.endIndex)])
        
        // split chars by output position indexes
        
        return lastChar
    }
    
    
    
    static func translateToString(toString: String, tableUnicode: String) -> String{
        let sourceString = toString
        var sourceUTF16 = Array(sourceString.utf16)
        var sourceLength = CInt(sourceUTF16.count)
        let maxBufferSize = 10000
        var destUTF16 = Array<UInt16>(repeating: 0, count: maxBufferSize)
        var destLength = CInt(destUTF16.count)
        lou_backTranslateString(tableUnicode, &sourceUTF16, &sourceLength, &destUTF16, &destLength, nil, nil, 256)
        
   
        let destString = String(utf16CodeUnits: destUTF16, count: Int(destLength))
        
//        let destStringData = Data(bytes: destUTF16, count: Int(destLength))
//        let destString = String(data: destStringData, encoding: .utf8)
//
        return destString
    }
    
    static func translateAndReverse(toBraille: String, tableUnicode: String) -> LiblouisObject{
        let sourceString = toBraille.lowercased()
        var sourceUTF16 = Array(sourceString.utf16)
        var sourceLength = CInt(sourceUTF16.count)
        let maxBufferSize = 10000
        var destUTF16 = Array<UInt16>(repeating: 0, count: maxBufferSize)
        var destLength = CInt(destUTF16.count)
        
        // set input and ouput postion
    
        var inputPos: [Int32] = Array<Int32>(repeating: 0, count: destUTF16.count)
        var outPutPos: [Int32] = Array<Int32>(repeating: 0, count: sourceUTF16.count)
    
        // liblouis translate
        lou_translate(tableUnicode, &sourceUTF16, &sourceLength, &destUTF16, &destLength, nil, nil, &outPutPos, &inputPos, nil, 256)
        
        
        let destString = String(utf16CodeUnits: destUTF16, count: Int(destLength))
        
        // split chars by output position indexes
        

        
        let arrayOfChars = getArrayOfCharsByIndexes(english: toBraille, braille: destString, arrayOfIndexes: outPutPos)
        let liblouisObj = LiblouisObject(englishWord: toBraille, brailleWord: destString, indexesOfEnglishChars: outPutPos, indexesOfBrailleChars: inputPos, arrayOfChars: arrayOfChars)
        
        return liblouisObj
    }
    
        
}

