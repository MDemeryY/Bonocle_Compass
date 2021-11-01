//
//  HeaderView.swift
//  Bonocle_Compass
//
//  Created by Mahmoud ELDemery on 01/11/2021.
//

import UIKit

class HeaderView: UIView {

 
    //MARK: - View Life Cycle
 
        override func awakeFromNib() {
            super.awakeFromNib()
            
        }
        

        
        /// - Returns: GeographyInfoView
        class func loadingHeaderView() -> HeaderView {
            return Bundle.main.loadNibNamed("HeaderView", owner: nil, options: nil)?.first as! HeaderView
        }
        


}

