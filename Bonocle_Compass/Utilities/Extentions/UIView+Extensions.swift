//
//  UIView+Constraints.swift
//  My Etisalat
//
//  Created by Mahmoud ELDemery on 12/06/2021.
//  Copyright © 2019 Etisalat Misr. All rights reserved.
//

import Foundation

import UIKit

extension UIView {

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
           let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
           let mask = CAShapeLayer()
           mask.path = path.cgPath
           self.layer.mask = mask
       }

    func constrainToEdges(_ subview: UIView) {

        subview.translatesAutoresizingMaskIntoConstraints = false

        let topContraint = NSLayoutConstraint(
            item: subview,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 0)

        let bottomConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0)

        let leadingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0)

        let trailingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0)

        addConstraints([
            topContraint,
            bottomConstraint,
            leadingContraint,
            trailingContraint])
    }

    func constrainToEdges(_ subview: UIView,top: CGFloat?, left: CGFloat?, bottom: CGFloat?, right: CGFloat?) {

        subview.translatesAutoresizingMaskIntoConstraints = false

        if let topValue = top {
            let topContraint = NSLayoutConstraint(
            item: subview,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: topValue)
            addConstraint(topContraint)
        }
        
        if let bottomValue = bottom {
            let bottomConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: bottomValue)
            addConstraint(bottomConstraint)
        }
        
        if let leftValue = left {
            let leadingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: leftValue)
            addConstraint(leadingContraint)
        }

        if let rightValue = right {
            let trailingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1.0,
            constant: rightValue)
            addConstraint(trailingContraint)
        }
    }
    
    func dropShadow(shadowOffsetWidth:Int) {
               // shadow
            self.layer.shadowColor = UIColor.gray.cgColor
            self.layer.shadowOffset = CGSize(width: 1, height: 1)
            self.layer.shadowOpacity = 0.7
            self.layer.shadowRadius = 1
        }
    
    
    
      @IBInspectable var shadow: Bool {
              get {
                   return layer.shadowOpacity > 0.0
              }
              set {
                   if newValue == true {
                        self.addShadow()
                   }
              }
         }

    fileprivate func addShadow(shadowColor: CGColor = UIColor.gray.cgColor, shadowOffset: CGSize = CGSize(width: 0, height: 0), shadowOpacity: Float = 1.0, shadowRadius: CGFloat = 2.0) {
              let layer = self.layer
              layer.masksToBounds = false

              layer.shadowColor = UIColor.gray.cgColor
              layer.shadowOpacity = 1
              layer.shadowOffset = .zero
              layer.shadowRadius = 3

         }


         // Corner radius
         @IBInspectable var circle: Bool {
              get {
                   return layer.cornerRadius == self.bounds.width*0.5
              }
              set {
                   if newValue == true {
                        self.cornerRadius = self.bounds.width*0.5
                   }
              }
         }

         @IBInspectable var cornerRadius: CGFloat {
              get {
                   return self.layer.cornerRadius
              }

              set {
                   self.layer.cornerRadius = newValue
              }
         }


         // Borders
         // Border width
         @IBInspectable
         public var borderWidth: CGFloat {
              set {
                   layer.borderWidth = newValue
              }

              get {
                   return layer.borderWidth
              }
         }

         // Border color
         @IBInspectable
         public var borderColor: UIColor? {
              set {
                   layer.borderColor = newValue?.cgColor
              }

              get {
                   if let borderColor = layer.borderColor {
                        return UIColor(cgColor: borderColor)
                   }
                   return nil
              }
         }
    
    
}
extension UIColor {
    @nonobjc class var mainColor: UIColor {
        return UIColor.init(red: 36.0/255, green: 58.0/255, blue: 83.0/255, alpha: 1)
    }

}

extension UIView {
    func shadowDecorate() {
        let radius: CGFloat = 20
        self.layer.cornerRadius = radius
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.3
        layer.masksToBounds = false
        //layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 1).cgPath
        layer.cornerRadius = radius
    }
    
    func shadowCells() {
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.3
        layer.masksToBounds = false
    }
}

extension UICollectionView {
func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
   let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
   let mask = CAShapeLayer()
   mask.path = path.cgPath
   self.layer.mask = mask
}}




let screenH: CGFloat = UIScreen.main.bounds.height
let screenW: CGFloat = UIScreen.main.bounds.width


// MARK: - 扩展UIView
extension UIView {

    /// 视图的X值
    var LeftX: CGFloat {
        get {
            return self.frame.origin.x
        }
    }
    /// 视图右边的X值
    var RightX: CGFloat {
        get {
            return self.frame.origin.x + self.bounds.width
        }
    }
    /// 视图顶部Y值
    var TopY: CGFloat {
        get {
            return self.frame.origin.y
        }
    }
    /// 视图底部Y值
    var BottomY: CGFloat {
        get {
            return self.frame.origin.y + self.bounds.height
        }
    }

    /// 视图的宽度
    var Width: CGFloat {
        get {
            return self.bounds.width
        }
    }

    /// 视图的高度
    var Height: CGFloat {
        get {
            return self.bounds.height
        }
    }
}



extension String {

    func DegreeToString(d: Double) -> String {
        let degree = Int(d)
        print("\(degree)°")
        let tempMinute = Float(d - Double(degree)) * 60
        let minutes = Int(tempMinute)   // 取整
        print("\(minutes)‘")
        let second = Int((tempMinute - Float(minutes)) * 60)
        print(" \(second)\"")
        return "\(degree)°\(minutes)′\(second)″"
    }
}
