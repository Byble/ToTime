//
//  MarkAnnotation.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/25.
//  Copyright © 2020 김민국. All rights reserved.
//

import UIKit
import MapKit

class MarkAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
