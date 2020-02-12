//
//  AnimationExtension.swift
//  ToTime
//
//  Created by 김민국 on 2020/02/11.
//  Copyright © 2020 김민국. All rights reserved.
//

import Foundation
import SwiftUI

extension Animation {
    func `repeat`(while expression: Bool, autoreverses: Bool = true) -> Animation {
        if expression {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
    }
}
