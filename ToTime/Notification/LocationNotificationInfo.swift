//
//  LocationNotificationInfo.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/25.
//  Copyright © 2020 김민국. All rights reserved.
//

import CoreLocation

struct LocationNotificationInfo {
    
    let notificationId: String
    let locationId: String
    
    let title: String
    let body: String
    let data: [String: Any]?
}
