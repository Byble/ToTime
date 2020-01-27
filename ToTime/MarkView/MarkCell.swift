//
//  MarkCell.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/21.
//  Copyright © 2020 김민국. All rights reserved.
//

import SwiftUI
import MapKit

struct MarkCell: View {
    
    var name: String = "버튼 이름"
    var nameColor: Color
    var bgColor: Color
    var location: CLLocation
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

struct MarkCell_Previews: PreviewProvider {
    static var previews: some View {
        MarkCell(name: "버튼 이름", nameColor: Color.white, bgColor: Color.blue, location: CLLocation(latitude: 0.0, longitude: 0.0))
    }
}
