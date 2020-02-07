//
//  MarkData.swift
//  ToTime
//
//  Created by 김민국 on 2020/02/08.
//  Copyright © 2020 김민국. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit
import SwiftUI

class MarkData: Object{
    @objc dynamic var id = UUID()
    @objc dynamic let name: String = ""
    @objc dynamic var nameColor: Color = Color.white
    @objc dynamic var bgColor: Color = Color.white
    @objc dynamic var location: CLLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    @objc dynamic var address: String = ""
}
