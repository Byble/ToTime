//
//  ContentView.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/19.
//  Copyright © 2020 김민국. All rights reserved.
//

import SwiftUI
import QGrid
import MapKit

struct ContentView {
    @State var isNavigationBarHidden: Bool = true
    @State private var showAddMark: Bool = false
    
    @State var locName = ""
    @State var marks: [Mark] = []
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    let homeMapViewEnvironment = HomeMapViewEnvironment()
}

extension ContentView: View{
    var body: some View {
            NavigationView{
                Group{
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            VStack(alignment: .leading){
                                Text("지번, 도로명, 건물명을\n입력하세요")
                                .font(.system(size: 35))
                                    .padding(.top, 20)
                            }
                            .padding(.leading, 10)
                            .padding(.trailing, 10)

                            HStack(spacing: 5){
                                TextField("입력하세요", text: $locName)
                                    .padding(.all, 15)
                                    .background(lightGreyColor)
                                    .foregroundColor(Color.black)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray, lineWidth: 2)
                                    )

                                Spacer(minLength: 10)
                                if !self.locName.isEmpty{

                                    NavigationLink(destination: HomeMapView(isNavigationBarHidden: $isNavigationBarHidden, isLoc: true, address: self.locName).environmentObject(homeMapViewEnvironment)) {
                                        Image(systemName: "magnifyingglass").foregroundColor(Color.gray)
                                    }
                                    .padding(.all, 20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.gray, lineWidth: 2)
                                    )
                                    .background(lightGreyColor)
                                }
                                NavigationLink(destination: HomeMapView(isNavigationBarHidden: $isNavigationBarHidden, isLoc: false, address:"").environmentObject(homeMapViewEnvironment)) {
                                    Image(systemName: "map").foregroundColor(Color.gray)
                                }
                                .padding(.all, 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray, lineWidth: 2)
                                )
                                .background(lightGreyColor)
                            }
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .padding(.bottom, 30)
                        }
//
                        VStack(alignment: .leading){
                            HStack(alignment: .center){
                                Text("즐겨찾기")
                                .font(.system(size: 25))
                                Button(action: {
                                    self.showAddMark.toggle()
                                }){
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 25))
                                        .foregroundColor(Color.red)
                                }
                                .sheet(isPresented: self.$showAddMark) {
                                    AddMarkView(didAddMark: {
                                        mark in
                                        self.marks.append(mark)
                                    })
                                }
                            }
                        }
                        .padding(.leading, 20)

                        VStack(){
                            QGrid(marks, columns: 2){
                                mark in
                                MarkCell(name: mark.name,
                                        nameColor: mark.nameColor,
                                        bgColor: mark.bgColor,
                                        location: mark.location)
                                    .padding()
                            }
                        }
                    }
                }                
                .navigationBarTitle("")
                .navigationBarHidden(self.isNavigationBarHidden)
                .onAppear {
                    self.isNavigationBarHidden = true
                }
            }
            .onTapGesture {
                self.endEditing()
            }
            
        }
    private func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
