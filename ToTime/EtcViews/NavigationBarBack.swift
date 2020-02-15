//
//  NavigationBarBack.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/23.
//  Copyright © 2020 김민국. All rights reserved.
//

import SwiftUI

struct NavigationBarBack: View {


    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var btnBack : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
            Image("ic_back") // set image here
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                Text("뒤로가기")
            }
        }
    }

    var body: some View {
            List {
                Text("sample code")
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
    }
}

struct NavigationBarBack_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBarBack()
    }
}

