//
//  LocationNotificationSchedulerDelegate.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/25.
//  Copyright © 2020 김민국. All rights reserved.
//

import UserNotifications

protocol LocationNotificationSchedulerDelegate: UNUserNotificationCenterDelegate {
    
    func notificationPermissionDenied()
    
    func locationPermissionDenied()

    func notificationScheduled(error: Error?)
}
