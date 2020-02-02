//
//  MarkCell.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/21.
//  Copyright © 2020 김민국. All rights reserved.
//

import SwiftUI
import MapKit

struct TestMarkCell: View {
    
    var name: String = "버튼 이름"
    var nameColor: Color
    var bgColor: Color
    
    var body: some View {
        Button(action: {
            
        }){
            HStack{
                Text(name)
                .fontWeight(.bold)
                    .font(.system(.headline, design: .rounded))
            }
            .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.width/3.5)
            .padding(.all, 7)
            .foregroundColor(nameColor)
            .background(bgColor)
            .cornerRadius(40)
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                .stroke(bgColor, lineWidth: 4)
            )
        }
    }
}
