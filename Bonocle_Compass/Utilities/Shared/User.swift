//
//  User.swift
//  Bonocle_Spelling
//
//  Created by Mahmoud ELDemery on 01/08/2021.
//

import Foundation

// MARK: - Result
struct User: Codable {
    var firstName, lastName, email: String?
    var profileImage: String?
    var dateOfBirth: String?
    var activePackage: String?
    var devices: [Device]?
    var token: String?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case profileImage = "profile_image"
        case dateOfBirth = "date_of_birth"
        case activePackage = "active_package"
        case devices, token
    }
}

// MARK: - Device
struct Device: Codable {
    var macAddress, deviceName: String?
    var horizontalSpacing, verticalSpacing, vibrationSensitivity, scrollSpeed: Int?
    var rightHanded: Bool?
    var language: String?

    enum CodingKeys: String, CodingKey {
        case macAddress = "mac_address"
        case deviceName = "device_name"
        case horizontalSpacing = "horizontal_spacing"
        case verticalSpacing = "vertical_spacing"
        case scrollSpeed = "scroll_speed"
        case vibrationSensitivity = "vibration_sensitivity"
        case rightHanded = "right_handed"
        case language
    }
}
