//
//  AddMarkMapView.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/22.
//  Copyright © 2020 김민국. All rights reserved.
//

import SwiftUI
import MapKit

struct AddMarkMapView: View {
    
    @State private var isChange: Bool = false
    @State var isFocus: Bool = false
    @State private var errorField: String = ""
    @State private var getlocation: CLLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    @State var isLoading: Bool = false
    @State var getAddress: String = ""
    
    @Binding var isNavigationBarHidden: Bool
    @Binding var setLocation: CLLocation
    @Binding var setAddress: String
    
    var isLoc: Bool = false
    var address: String = ""
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        ZStack{
            NavigationItemContainer{
                
                VStack{
                    if !self.errorField.isEmpty{
                        Text(self.errorField)
                        .font(.title)
                    }
                    
                    ZStack{
                        ZStack(alignment: .topTrailing){
                            AddMarkMap(location: self.$getlocation, isLoc: self.isLoc, isChange: self.$isChange, isFocus: self.$isFocus, errorField: self.$errorField, isLoading: self.$isLoading, setAddress: self.$getAddress, address: self.address)
                                .onAppear(perform: {
                                    self.isLoading = true
                                })
                                                        
                            Button(action: {
                                self.isFocus.toggle()
                            }){
                                if !self.isFocus{
                                    Image(systemName: "location")
                                    .padding(15)
                                    .font(.title)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.blue, lineWidth: 4)
                                    )
                                }else{
                                    Image(systemName: "location.fill")
                                    .padding(15)
                                    .font(.title)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.blue, lineWidth: 4)
                                    )
                                }
                                
                            }.padding(.top, 30)
                                .padding(.trailing, 10)
                        }
                        ZStack(alignment: .center) {
                            if self.isChange{
                                Image(systemName: "circle")
                            }
                        }
                    }
                    
                    
                    Spacer()
                    HStack{
                        Spacer()
                        Button(action: {
                            if !self.errorField.isEmpty{
                                print(self.getAddress)
                                print(self.getlocation)
                                self.setAddress = self.getAddress
                                self.setLocation = self.getlocation
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }){
                            Text("선택완료")
                            .padding()
                        }
                        Spacer()
                        Button(action: {
                            self.isChange = true
                        }){
                            Text("변경하기")
                            .padding()
                        }
                        
                        Spacer()
                    }
                    Spacer()
                }
                .onAppear {
                    self.isNavigationBarHidden = false
                }
            }
            .blur(radius: self.isLoading ? CGFloat(3) : CGFloat(0))
            ActivityIndicator(style: .large, isLoading: self.$isLoading)
            
        }
    }
}

