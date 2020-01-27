//
//  HomeMapView.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/22.
//  Copyright © 2020 김민국. All rights reserved.
//

import SwiftUI
import MapKit

enum ALERT{
    case None
    case ScheduleError
    case Schedule
    case Reach
    case LocationSet
    case AlertSet
}

struct HomeMapView: View {
    @EnvironmentObject var homeMapViewEnvironment: HomeMapViewEnvironment
    
    @State private var isChange: Bool = false
    @State private var setDistance: Double = 100
    @State var isFocus: Bool = false
    @State private var errorField: String = ""
    
    @State private var showAlert: Bool = false
    @State private var location: CLLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    @State private var activeAlert: ALERT = .None
    
    @State var isLoading: Bool = false
    
    @Binding var isNavigationBarHidden: Bool
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
                            HomeMap(location: self.$location, isLoc: self.isLoc, isChange: self.$isChange, isFocus: self.$isFocus, setDistance: self.$setDistance, errorField: self.$errorField, showAlert: self.$showAlert, activeAlert: self.$activeAlert, isLoading: self.$isLoading, address: self.address, setStart: {
                                self.homeMapViewEnvironment.isStart = $0
                            })
                                .onAppear(perform: {
                                    self.isLoading = true
                                })
                            .alert(isPresented: self.$showAlert){
                                switch self.activeAlert{
                                    case .None:
                                        return Alert(title: Text("None"))
                                    case .ScheduleError:
                                        return self.defaultAlert(title: "알림 오류", message:"오류가 발생했습니다.")
                                    case .Schedule:
                                        return self.defaultAlert(title: "알림 설정 완료", message: "설정한 거리까지 도착하면 알림을 받습니다")
                                    case .Reach:
                                        return self.defaultAlert(title: "도착", message: "지정한 목적지 거리에 도착했습니다.")
                                    case .LocationSet:
                                        return self.actionAlert(title: "권한 설정 필요", message: "위치 권한이 승인되지 않았습니다. 계속하려면 설정에서 위치 권환을 활성화하십시오.")
                                    case .AlertSet:
                                        return self.actionAlert(title: "권한 설정 필요", message: "알림 권한이 부여되지 않았습니다. 계속하려면 설정에서 알림 권환을 활성화하십시오.")
                                }
                            }
                                                        
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
                            if (self.homeMapViewEnvironment.isStart ?? false) == false{
                                self.homeMapViewEnvironment.isStart = true
                                self.isChange = false
                                self.isFocus = true
                            }else{
                                self.homeMapViewEnvironment.isStart = false
                                self.isChange = false
                                self.isFocus = false
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            }
                        }){
                            if (self.homeMapViewEnvironment.isStart ?? false) == false{
                                Text("시작하기")
                                .padding()
                            }else{
                                Text("중지하기")
                                .padding()
                            }
                        }
                        
                        Spacer()
                        Button(action: {
                            self.isChange = true
                            self.homeMapViewEnvironment.isStart = false
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
            .blur(radius: self.isLoading ? 3 : 0)
            ActivityIndicator(style: .large, isLoading: self.$isLoading)
            
        }
    }

    private func defaultAlert(title: String, message: String) -> Alert{
        return Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK"), action: {
            self.toggleShowAlert()
        }))
    }

    private func actionAlert(title: String, message: String) -> Alert{
        return Alert(title: Text(title), message: Text(message), primaryButton: .default(Text("OK")), secondaryButton: .default(Text("설정"), action: {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            self.toggleShowAlert()
        }))
    }

    private func toggleShowAlert(){
        self.showAlert = false
        self.activeAlert = .None
    }
}
//
//struct HomeMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeMapView(isNavigationBarHidden: Binding.constant(true), address: "서울")
//    }
//}
