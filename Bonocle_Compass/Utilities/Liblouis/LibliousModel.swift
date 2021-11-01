//
//  LibliousModel.swift
//  Bonocle_PeriodicTable
//
//  Created by Mahmoud ELDemery on 28/09/2021.
//

import Foundation

struct LiblouisObject:Codable {
    var englishWord = String()
    var brailleWord = String()
    var indexesOfEnglishChars = [Int32]()
    var indexesOfBrailleChars = [Int32]()
    var arrayOfChars = [String]()

}


struct Word:Codable {
    var brailleChar = String()
    var englishChar = String()
    var brailleCharRange = NSMakeRange(0, 0)
    var englishCharRange = NSMakeRange(0, 0)
}
