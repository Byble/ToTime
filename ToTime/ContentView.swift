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
import RealmSwift

enum MarkMode{
    case None
    case Quick
    case Delete
}

struct ContentView {
    @State var isNavigationBarHidden: Bool = true
    @State private var showAddMark: Bool = false
    
    @State var locName = ""
    @State var markRealm = MarkRealm()
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    let homeMapViewEnvironment = HomeMapViewEnvironment()
    let quickMapViewEnvironment = QuickMapViewEnvironment()

    @State var markMode: MarkMode = .None
    @State var delAnim: Bool = false
    @State var markAnim: Bool = false
    @State var isMarkDelete: Bool = false
    @State var selectedID = ""
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

                                    NavigationLink(destination: HomeMapView(isNavigationBarHidden: $isNavigationBarHidden, isLoc: true, address: self.locName).environmentObject(homeMapViewEnvironment).onAppear(perform: {
                                        self.markMode = .None
                                    })) {
                                        Image(systemName: "magnifyingglass").foregroundColor(Color.gray)
                                        .padding(.all, 20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray, lineWidth: 2)
                                        )
                                        .background(lightGreyColor)
                                    }
                                }
                                NavigationLink(destination: HomeMapView(isNavigationBarHidden: $isNavigationBarHidden, isLoc: false, address:"").environmentObject(homeMapViewEnvironment).onAppear(perform: {
                                    self.markMode = .None
                                })) {
                                    Image(systemName: "map").foregroundColor(Color.gray)
                                    .padding(.all, 20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.gray, lineWidth: 2)
                                    )
                                    .background(lightGreyColor)
                                }
                            }
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .padding(.bottom, 30)
                        }

                        VStack(alignment: .leading){
                            HStack(alignment: .center){
                                Text("즐겨찾기")
                                .font(.system(size: 25))
                                .padding(.trailing, 5)
                                
                                Button(action: {
                                    self.showAddMark.toggle()
                                    self.markMode = .None
                                }){
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 25))
                                        .foregroundColor(Color.red)
                                }
                                .sheet(isPresented: self.$showAddMark) {
                                    AddMarkView(didAddMark: {
                                        mark in
                                        self.saveData(name: mark.name, nameColor: mark.nameColor, bgColor: mark.bgColor, latitude: mark.latitude, longitude: mark.longitude, address: mark.address)
                                        
                                    })
                                }
                                .padding(.trailing, 10)
                                
                                Button(action: {
                                    if self.markMode == MarkMode.Delete{
                                        self.markMode = .None
                                    }else{
                                        self.markMode = .Delete
                                    }
                                }){
                                    if self.markMode == MarkMode.Delete{
                                        Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 25))
                                        .foregroundColor(Color.red)
                                        .scaleEffect(self.delAnim ? 1.2:1)
                                        .animation(self.delAnim ? Animation.default.repeatForever(autoreverses: true) : .default)
                                        .onAppear {
                                            self.delAnim = true
                                        }
                                    }else{
                                        Image(systemName: "minus.circle")
                                        .font(.system(size: 25))
                                        .foregroundColor(Color.red)
                                        .onAppear {
                                            self.delAnim = false
                                        }
                                    }
                                }
                                .alert(isPresented: self.$isMarkDelete){
                                    return Alert(title: Text("삭제 알림"), message: Text("선택하신 즐겨찾기를 삭제하시겠습니까?"), primaryButton: .cancel({
                                        self.isMarkDelete = false
                                        self.selectedID = ""
                                    }), secondaryButton: .default(Text("확인"), action: {
                                        if (self.selectedID != ""){
                                            self.markRealm.deleteMark(id: self.selectedID)
                                        }
                                        self.selectedID = ""
                                        self.isMarkDelete = false
                                    }))
                                }
                            }
                        }
                        .padding(.leading, 20)

                        VStack(){
                            QGrid(markRealm.getMarks(), columns: 2){
                                mark in
                                MarkCell(name: mark.name,
                                         nameColor: Color(UIColor(hex: mark.nameColor) ?? UIColor.blue),
                                         bgColor: Color(UIColor(hex: mark.bgColor) ?? UIColor.red),
                                    location: CLLocation(latitude: mark.latitude, longitude: mark.longitude),
                                    address: mark.address,
                                    didClick: {_ in
                                        self.selectedID = mark.uuid
                                        if self.markMode != MarkMode.Delete{
                                            self.markMode = .Quick
                                        }else{
                                            self.isMarkDelete = true
                                        }
                                })
                                .padding()
//                                .rotationEffect(.degrees(self.delAnim ? -5 : self.markMode == MarkMode.Delete ? 5 : 0), anchor: .center)
//                                .animation(self.delAnim ? Animation.default.repeatForever(autoreverses: true) : .default)
//                                .animation(Animation.linear(duration: 0.3).repeat(while: self.delAnim))
                            }
                        }
                        if selectedID != ""{
                            if self.markMode == .Quick{
                                NavigationLink(destination: QuickMapView(address: self.markRealm.getMark(id: self.selectedID).address, location: CLLocation(latitude: self.markRealm.getMark(id: self.selectedID).latitude, longitude: self.markRealm.getMark(id: self.selectedID).longitude),  isNavigationBarHidden: self.$isNavigationBarHidden).environmentObject(quickMapViewEnvironment)
                                    .onDisappear(perform: {
                                        self.markMode = .None
                                    }),
                                               isActive: self.markMode == MarkMode.Quick ? Binding.constant(true) : Binding.constant(false)){
                                    EmptyView()
                                }
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
    
    private func saveData(name: String, nameColor: String, bgColor: String, latitude: Double, longitude: Double, address: String){
        
        let data = MarkData()
        data.name = name
        data.nameColor = nameColor
        data.bgColor = bgColor
        data.latitude = latitude
        data.longitude = longitude
        data.address = address
        
        markRealm.saveMark(obj: data)
    }
}
