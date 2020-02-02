//
//  Mark.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/21.
//  Copyright © 2020 김민국. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit

struct Mark: Identifiable {
    var id = UUID()
    let name: String
    let nameColor: Color
    let bgColor: Color
    let location: CLLocation
    let address: String
}

