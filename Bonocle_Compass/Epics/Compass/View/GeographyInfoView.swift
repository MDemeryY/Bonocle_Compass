//
//  GeographyInfoView.swift
//  CompassExample
//
//  Created by Mahmoud ELDemery on 01/11/2021.
//


import UIKit


class GeographyInfoView: UIView {
    
    //MARK: - Control Properties
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var latitudeAndLongitudeLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    
}

//MARK: - View Life Cycle
extension GeographyInfoView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}

extension GeographyInfoView {
    
    /// - Returns: GeographyInfoView
    class func loadingGeographyInfoView() -> GeographyInfoView {
        return Bundle.main.loadNibNamed("GeographyInfoView", owner: nil, options: nil)?.first as! GeographyInfoView
    }
    
}
