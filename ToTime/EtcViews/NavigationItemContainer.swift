//
//  NavigationItemContainer.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/25.
//  Copyright © 2020 김민국. All rights reserved.
//

import SwiftUI

struct NavigationItemContainer<Content>: View where Content: View {
    private let content: () -> Content
    @Environment(\.presentationMode) var presentationMode

    private var btnBack : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
    }) {
        HStack {
            Image(systemName: "chevron.left")
                .aspectRatio(contentMode: .fit)
            Text("back")
        }
        }
    }

    var body: some View {
        content()
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
        
    }

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
}
