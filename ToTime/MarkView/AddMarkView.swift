//
//  AddMarkView.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/21.
//  Copyright © 2020 김민국. All rights reserved.
//

import SwiftUI
import MapKit

struct AddMarkView: View {
    @Environment (\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var isNavigationBarHidden: Bool = true
    @State var locName = ""
    @State var fullLoc = ""
    @State var markName = ""
    @State var bgColor = Color.black
    @State var nameColor = Color.white
    @State var location = CLLocation(latitude: 0.0, longitude: 0.0)
    
    @State var currentBgColor: Color = .clear
    @State var currentNameColor: Color = .clear
    
    let defaultLoc = CLLocation(latitude: 0.0, longitude: 0.0)
    
    var didAddMark: (Mark) -> ()
    
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    
    @State var isAlert: Bool = false
    
    var body: some View {
        NavigationView{
            Group{
                VStack(alignment: .center){
                        HStack(){
                            Spacer()
                            Button(action: {
                                if self.markName != "" && self.location != self.defaultLoc{
                                    self.didAddMark(.init(name: self.markName, nameColor: self.currentNameColor, bgColor: self.currentBgColor, location: self.location, address: self.fullLoc))
                                    self.presentationMode.wrappedValue.dismiss()
                                }else{
                                    self.isAlert = true
                                }
                            }){
                                Text("Done")
                                    .font(.headline)
                                .padding(15)
                            }
                            .alert(isPresented: $isAlert, content: {
                                Alert(title: Text("오류 발생"), message: Text("완료하지 않은 항목이 있습니다."), dismissButton: .default(Text("완료"), action: {
                                    self.isAlert = false
                                }))
                            })
                        }
                        
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

                                    NavigationLink(destination: AddMarkMapView(isNavigationBarHidden: $isNavigationBarHidden, setLocation: $location, setAddress: $fullLoc, isLoc: true, address: locName)) {
                                        Image(systemName: "magnifyingglass").foregroundColor(Color.gray)
                                        .padding(.all, 20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray, lineWidth: 2)
                                        )
                                        .background(lightGreyColor)
                                    }
                                }
                                NavigationLink(destination: AddMarkMapView(isNavigationBarHidden: $isNavigationBarHidden, setLocation: $location, setAddress: $fullLoc, isLoc: false, address: locName)) {
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
                        HStack(alignment: .center){
                            Text(fullLoc != "" ? fullLoc : "입력된 주소가 없습니다.")
                        }

                        VStack(alignment: .leading){
                            HStack(alignment: .center){
                                Text("이름")
                                    .padding()
                                    .padding(.trailing, 30)
                                TextField("입력하세요", text: $markName)
                                    .padding(.all, 8)
                                .foregroundColor(Color.black)
                                .background(lightGreyColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.gray, lineWidth: 2)
                                )
                            }
                            .padding()
                            .padding(.trailing, 30)
                        }
                        .padding(.bottom, 10)

                        VStack(alignment: .center){
                            HStack(){
                                Spacer()
                                VStack(){
                                    ZStack(alignment: .topTrailing) {
                                        ColorPickerView(chosenColor: $currentBgColor)
                                    }
                                    Text("배경 색상")
                                    .padding()
                                }
                                Spacer()
                                VStack(){
                                    ZStack(alignment: .topTrailing) {
                                        ColorPickerView(chosenColor: $currentNameColor)
                                    }
                                    Text("이름 색상")
                                    .padding()
                                }
                                Spacer()
                            }
                        }
                        Spacer()
                        TestMarkCell(name: markName != "" ? markName : "버튼 이름", nameColor: currentNameColor, bgColor: currentBgColor)
                        Spacer()
                    }
                }
                .navigationBarTitle("")
                .navigationBarHidden(isNavigationBarHidden)
                .onAppear{
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

struct AddMarkView_Previews: PreviewProvider {
    static var previews: some View {
        AddMarkView(didAddMark: {_ in })
    }
}
