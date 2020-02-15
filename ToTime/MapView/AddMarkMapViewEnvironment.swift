//
//  AddMarkMapViewEnvironment.swift
//  ToTime
//
//  Created by 김민국 on 2020/02/15.
//  Copyright © 2020 김민국. All rights reserved.
//

import Foundation

class AddMarkMapViewEnvironment: ObservableObject {
    var didIsOverTimeChange: (()->Void)?
    
    @Published var isOverTime: Bool? {
        didSet {
            if let didIsOverTimeChange = didIsOverTimeChange {
                didIsOverTimeChange()
            }
        }
    }
}

