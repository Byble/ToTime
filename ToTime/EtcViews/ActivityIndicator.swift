//
//  ActivityIndicator.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/27.
//  Copyright © 2020 김민국. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {

    typealias UIViewType = UIActivityIndicatorView

    let style: UIActivityIndicatorView.Style
    @Binding var isLoading: Bool
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> ActivityIndicator.UIViewType {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: ActivityIndicator.UIViewType, context: UIViewRepresentableContext<ActivityIndicator>) {
        isLoading ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
