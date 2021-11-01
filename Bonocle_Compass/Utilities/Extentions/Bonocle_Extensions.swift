//
//  Extensions.swift
//  BonocleReader
//
//  Created by Abdelrazek Aly on 1/2/20.
//  Copyright © 2020 Bonocle. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension UIResponder {
  
  func getOwningViewController() -> UIViewController? {
    var nextResponser = self
    while let next = nextResponser.next {
      nextResponser = next
      if let viewController = nextResponser as? UIViewController {
        return viewController
      }
    }
    return nil
  }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension Int {
    func hexadecimal() -> Int {
        return Int(String(self), radix: 16)!
    }
    
    func hexadecimalByte() -> UInt8 {
        return UInt8(Int(String(self), radix: 16)!)
    }
    
    func toUInt8() -> UInt8 {
        return UInt8(String(self, radix: 16), radix: 16)!
    }
}

extension CBCharacteristic {
    func hasUUID(uuid: String) -> Bool {
        return (self.uuid.uuidString == uuid)
    }
}

extension CBService {
    func hasUUID(uuid: String) -> Bool {
        return (self.uuid.uuidString == uuid)
    }
}

extension Data {
    func hexEncodedoneString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    func hexEncodedString() -> String {
        return map { String(format: "%d ", Int($0)) }.joined()
    }
    
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }
            .joined()
    }
    
    init<T>(fromArray values: [T]) {
        var values = values
        self.init(buffer: UnsafeBufferPointer(start: &values, count: values.count))
    }

    func toArray<T>(type: T.Type) -> [T] {
        let value = self.withUnsafeBytes {
            $0.baseAddress?.assumingMemoryBound(to: T.self)
        }
        return [T](UnsafeBufferPointer(start: value, count: self.count / MemoryLayout<T>.stride))
    }

}

extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: CountableRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: CountablePartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}

extension String {
    
    var hexadecimal: Data? {
        var data = Data(capacity: self.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
    /// Create `String` representation of `Data` created from hexadecimal string representation
    ///
    /// This takes a hexadecimal representation and creates a String object from that. Note, if the string has any spaces, those are removed. Also if the string started with a `<` or ended with a `>`, those are removed, too.
    ///
    /// For example,
    ///
    ///     String(hexadecimal: "<666f6f>")
    ///
    /// is
    ///
    ///     Optional("foo")
    ///
    /// - returns: `String` represented by this hexadecimal string.
    
    init?(hexadecimal string: String, encoding: String.Encoding = .utf8) {
        guard let data = string.hexadecimal else {
            return nil
        }
        
        self.init(data: data, encoding: encoding)
    }
    
    /// Create hexadecimal string representation of `String` object.
    ///
    /// For example,
    ///
    ///     "foo".hexadecimalString()
    ///
    /// is
    ///
    ///     Optional("666f6f")
    ///
    /// - parameter encoding: The `String.Encoding` that indicates how the string should be converted to `Data` before performing the hexadecimal conversion.
    ///
    /// - returns: `String` representation of this String object.
    
    func hexadecimalString(encoding: String.Encoding = .utf8) -> String? {
        return data(using: encoding)?
            .hexadecimal
    }
    
    func getParaghraphs() -> [String] {
        let range = self.startIndex..<self.endIndex
        var paraghraphs: [String] = Array()
        self.enumerateSubstrings(in: range, options: .byParagraphs) { (paragraph, paragraphRange, enclosingRange, stop) -> () in

        //    guard let range = Range(paragraphRange, in: paragraph)
            let paraghraph = self[paragraphRange]
            paraghraphs.append(String(paraghraph))
        }
        
        return paraghraphs
    }
    
    func getLines() -> [String] {
        let range = self.startIndex..<self.endIndex
        var paraghraphs: [String] = Array()
        self.enumerateSubstrings(in: range, options: .byLines) { (paragraph, paragraphRange, enclosingRange, stop) -> () in

        //    guard let range = Range(paragraphRange, in: paragraph)
            let paraghraph = self[paragraphRange]
            paraghraphs.append(String(paraghraph))
        }
        
        return paraghraphs
    }
    
    func getWords() -> [String] {
        let range = self.startIndex..<self.endIndex
        var paraghraphs: [String] = Array()
        self.enumerateSubstrings(in: range, options: .byWords) { (paragraph, paragraphRange, enclosingRange, stop) -> () in

        //    guard let range = Range(paragraphRange, in: paragraph)
            let paraghraph = self[paragraphRange]
            paraghraphs.append(String(paraghraph))
            paraghraphs.append(" ")
        }
        paraghraphs.remove(at: paraghraphs.count-1)
        return paraghraphs
    }
    
    func getSentences() -> [String] {
        let range = self.startIndex..<self.endIndex
        var paraghraphs: [String] = Array()
        self.enumerateSubstrings(in: range, options: .bySentences) { (paragraph, paragraphRange, enclosingRange, stop) -> () in

        //    guard let range = Range(paragraphRange, in: paragraph)
            let paraghraph = self[paragraphRange]
            paraghraphs.append(String(paraghraph))
        }
        
        return paraghraphs
    }

    
}
