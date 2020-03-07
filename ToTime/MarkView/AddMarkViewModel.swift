//
//  AddMarkViewModel.swift
//  ToTime
//
//  Created by 김민국 on 2020/03/08.
//  Copyright © 2020 김민국. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import CoreLocation

class AddMarkViewModel: ObservableObject{
    @Published var isNavigationBarHidden: Bool = true
    @Published var locName = ""
    @Published var fullLoc = ""
    @Published var markName = ""
    @Published var location = CLLocation(latitude: 0.0, longitude: 0.0)
    @Published var iconInx = 0
    
    let defaultLoc = CLLocation(latitude: 0.0, longitude: 0.0)
    @Published var dataManager = DataManager()
    
    @Published var isAlert: Bool = false
    
    
}

extension AddMarkViewModel{
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
}
