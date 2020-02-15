//
//  ProgressView.swift
//  ToTime
//
//  Created by 김민국 on 2020/02/15.
//  Copyright © 2020 김민국. All rights reserved.
//

import SwiftUI

struct ProgressView: View {
    @State private var pulsate = false

    @Binding var percentage: Float
    
    var outLineColors: [Color] = [Color.outlineColor]
    var trackColors: [Color] = [Color.trackColor]
    var pulColors: [Color] = [Color.pulsatingColor]

    var body: some View {
        ZStack {
            Color.backgroundColor
                .edgesIgnoringSafeArea(.all)
            VStack {
                ZStack {
                    ZStack {
                        Circle()
                            .fill(Color.pulsatingColor)
                            .frame(width: UIScreen.main.bounds.width/2-5, height: UIScreen.main.bounds.width/2-5)
                            .scaleEffect(pulsate ? 1.3 : 1.1)
                            .animation(Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true))
                            .onAppear{
                                self.pulsate.toggle()
                        }
                    }
                    ZStack {
                        Circle()
                            .fill(Color.backgroundColor)
                            .frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
                        .overlay(
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 20))
                            .fill(AngularGradient(gradient: .init(colors: trackColors), center: .center))
                        )
                    }
                    ZStack {
                        Text(String(format: "%.0f", min(self.percentage, 100.0))+"%").font(.system(size: 65)).fontWeight(.heavy).colorInvert()
                    }
                    ZStack {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
                        .overlay(
                        Circle()
                            .trim(from: 0, to: CGFloat(min(self.percentage, 100.0)) * 0.01)
                            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                            .fill(AngularGradient(gradient: .init(colors: outLineColors), center: .center, startAngle: .zero, endAngle: .init(degrees: 360)))
                        ).animation(.spring(response: 2.0, dampingFraction: 1.0, blendDuration: 1.0))
                    }
                }
            }
        }
    }
}

//struct Label: View{
//
//    var body: some View {
//
//    }
//}

//struct OutLine: View {
//    var percentage: CGFloat = 0
//
//    var body: some View {
//
//    }
//}

//struct Track: View {
//
//    var body: some View{
//
//    }
//}

//struct Pulsation: View{
//
//    var body: some View {
//
//    }
//}

//struct ProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgressView(distance: Binding.constant(0))
//    }
//}
