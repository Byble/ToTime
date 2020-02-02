//
//  HomeMapViewEnvironment.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/25.
//  Copyright © 2020 김민국. All rights reserved.
//
import Foundation

class QuickMapViewEnvironment: ObservableObject {
    var didIsStartChange: (()->Void)?
    
    @Published var isStart: Bool? {
        didSet {
            if let didIsStartChange = didIsStartChange {
                didIsStartChange()
            }
        }
    }
}

