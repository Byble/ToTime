//
//  MarkData.swift
//  ToTime
//
//  Created by 김민국 on 2020/02/08.
//  Copyright © 2020 김민국. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftUI

class MarkData: Object, Identifiable{
    @objc dynamic var uuid: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var address: String = ""
    @objc dynamic var iconName: String = ""
    
    convenience init(name: String, longitude: Double, latitude: Double, address: String, iconName: String){
        self.init()
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
        self.address = address
        self.iconName = iconName
    }
    
    override static func primaryKey() -> String? {
      return "uuid"
    }
}
