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
          
    var didAddMark: (MarkData) -> ()
    
    @ObservedObject var addMarkViewModel = AddMarkViewModel()
    
    var body: some View {
        NavigationView{
            Group{
                VStack(alignment: .center){
                        HStack(){
                            Spacer()
                            Button(action: {
                                if self.addMarkViewModel.markName != "" && self.addMarkViewModel.location != self.addMarkViewModel.defaultLoc{
                                    self.didAddMark(MarkData(name: self.addMarkViewModel.markName, longitude: self.addMarkViewModel.location.coordinate.longitude, latitude: self.addMarkViewModel.location.coordinate.latitude, address: self.addMarkViewModel.fullLoc, iconName: self.addMarkViewModel.dataManager.names[self.addMarkViewModel.iconInx]))

                                    self.presentationMode.wrappedValue.dismiss()
                                }else{
                                    self.addMarkViewModel.isAlert = true
                                }
                            }){
                                Text("완료")
                                    .font(.headline)
                                .padding(15)
                            }
                            .alert(isPresented: $addMarkViewModel.isAlert, content: {
                                Alert(title: Text("오류 발생"), message: Text("완료하지 않은 항목이 있습니다."), dismissButton: .default(Text("완료"), action: {
                                    self.addMarkViewModel.isAlert = false
                                }))
                            })
                        }
                        VStack{
                            HStack(alignment: .center){
                                Text(addMarkViewModel.fullLoc != "" ? addMarkViewModel.fullLoc : "입력된 주소가 없습니다.")
                            }

                            VStack(alignment: .leading){
                                Text("즐겨찾기 이름")
                                .font(.system(size: 20))
                                    .padding()
                                    .padding(.top, 20)

                                TextField("입력하세요", text: $addMarkViewModel.markName)
                                    .padding(.all, 15)
                                    .background(Color.lightGreyColor)
                                    .foregroundColor(Color.black)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray, lineWidth: 2)
                                    )
                                    .padding(.leading, 10)
                                    .padding(.trailing, 10)
                            }
                            .padding(.bottom, 10)
                        }
                    
                        VStack(alignment: .leading){
                            Text("주소를 입력해주세요.")
                                .font(.system(size: 20))
                                .padding()
                                .padding(.top, 20)

                            HStack(spacing: 5){
                                TextField("입력하세요", text: $addMarkViewModel.locName)
                                    .padding(.all, 15)
                                    .background(Color.lightGreyColor)
                                    .foregroundColor(Color.black)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray, lineWidth: 2)
                                    )

                                Spacer(minLength: 10)
                                if !self.addMarkViewModel.locName.isEmpty{
                                    NavigationLink(destination: AddMarkMapView(isNavigationBarHidden: self.$addMarkViewModel.isNavigationBarHidden, setLocation: self.$addMarkViewModel.location, setAddress: self.$addMarkViewModel.fullLoc, isLoc: true, address: self.addMarkViewModel.locName)) {
                                        Image(systemName: "magnifyingglass").foregroundColor(Color.gray)
                                        .padding(.all, 20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray, lineWidth: 2)
                                        )
                                        .background(Color.lightGreyColor)
                                    }
                                }

                                NavigationLink(destination: AddMarkMapView(isNavigationBarHidden: self.$addMarkViewModel.isNavigationBarHidden, setLocation: self.$addMarkViewModel.location, setAddress: self.$addMarkViewModel.fullLoc, isLoc: false, address: self.addMarkViewModel.locName)) {
                                    Image(systemName: "map").foregroundColor(Color.gray)
                                    .padding(.all, 20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.gray, lineWidth: 2)
                                    )
                                    .background(Color.lightGreyColor)
                                }
                            }
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .padding(.bottom, 50)
                        }
                    
                        
                        VStack{
                            HStack{
                                Image(uiImage: loadIcon(fileName: self.addMarkViewModel.dataManager.names[addMarkViewModel.iconInx])!)
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.width/11, height: UIScreen.main.bounds.width/11)
                                    .padding(.trailing, 30)
                                VStack{
                                    Image(systemName: "arrowtriangle.up")
                                        .padding(.bottom, 5)
                                    Picker(selection: $addMarkViewModel.iconInx, label: Text("")) {
                                        ForEach(0 ..< addMarkViewModel.dataManager.names.count){ index in
                                            Text(getFileName(fullURL: self.addMarkViewModel.dataManager.names[index]))
                                        }
                                    }
                                    .labelsHidden()
                                    .frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/10)
                                    .clipped()
                                    Image(systemName: "arrowtriangle.down")
                                        .padding(.top, 5)
                                }
                                
                            }
                            
                        }
                        Spacer()
                    }
                }
                .navigationBarTitle("")
                .navigationBarHidden(addMarkViewModel.isNavigationBarHidden)
                .onAppear{
                    self.addMarkViewModel.isNavigationBarHidden = true
                }
            }
        .onTapGesture {
            self.addMarkViewModel.endEditing()
        }
    }
}

struct AddMarkView_Previews: PreviewProvider {
    static var previews: some View {
        AddMarkView(didAddMark: {_ in })
    }
}
