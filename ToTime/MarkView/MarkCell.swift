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
//    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var name: String = "버튼 이름"
    var nameColor: Color
    var bgColor: Color
    var location: CLLocation
    var address: String = ""
    
    var didClick: (Bool) -> Void
//    @GestureState private var longPressTap = false
    
    var body: some View {
//        ZStack{
//            Group{
//                RoundedRectangle(cornerRadius: 40)
//                HStack{
//                    Text(name)
//                    .fontWeight(.bold)
//                        .font(.system(.headline, design: .rounded))
//                }
//                .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.width/3.5)
//                .padding(.all, 7)
//                .foregroundColor(nameColor)
//                .background(bgColor)
//                .cornerRadius(40)
//                .padding(8)
//                .background(Color.backgroundColor(for: colorScheme))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 40)
//                    .stroke(bgColor, lineWidth: 4)
//                )
//            }
//            .gesture(
//                LongPressGesture(minimumDuration: 1.0)
//                    .updating($longPressTap, body: { (currentState, state, transaction) in
//                        state = currentState
//                    })
//                    .onEnded({ _ in
//                        self.didClick(true)
//                    })
//            )
//        }
//        .opacity(longPressTap ? 0.4 : 1.0)
        
            
        Button(action: {
            self.didClick(true)
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
