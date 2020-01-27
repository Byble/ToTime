//
//  Background.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/23.
//  Copyright © 2020 김민국. All rights reserved.
//

import SwiftUI

struct Background<Content: View>: View {
    private var content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        Color(UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.001))
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .overlay(content)
    }
}
