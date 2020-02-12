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
import UIKit

struct Mark: Identifiable, Equatable {
    var id = UUID()
    let name: String
    let nameColor: UIColor
    let bgColor: UIColor
    let location: CLLocation
    let address: String
}

