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
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var nameColor: String = ""
    @objc dynamic var bgColor: String = ""
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var address: String = ""
    
    convenience init(name: String, nameColor: String, bgColor: String, longitude: Double, latitude: Double, address: String){
        self.init()
        self.name = name
        self.nameColor = nameColor
        self.bgColor = bgColor
        self.longitude = longitude
        self.latitude = latitude
        self.address = address
    }
}
