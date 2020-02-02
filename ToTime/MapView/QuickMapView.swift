//
//  QuickMapView.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/22.
//  Copyright © 2020 김민국. All rights reserved.
//

import SwiftUI
import MapKit

struct QuickMapView: View {
    @EnvironmentObject var quickMapViewEnvironment: QuickMapViewEnvironment
    
    @State private var setDistance: String = ""
    @State var isFocus: Bool = false
    @State private var errorField: String = ""
    
    @State private var showAlert: Bool = false
    @State private var showError: Bool = false
    @State private var activeAlert: ALERT = .None
    @State var distance: Int = 0
    
    @State var isLoading: Bool = false
    
    let address: String
    let location: CLLocation
    @Binding var isQuick: Bool
    @Binding var isNavigationBarHidden: Bool
    
    var body: some View {
        ZStack{
            NavigationItemContainer{                
                VStack{
                    if self.distance > 0{
                        Text("목적지 까지 \(self.distance) m")
                        HStack{
                            TextField("설정 거리를 입력하세요", text: self.$setDistance)
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .frame(width: UIScreen.main.bounds.width/2)
                            .padding()
                            Text("m")
                        }
                    }
                    
                    
                    
                    if !self.errorField.isEmpty{
                        Text(self.errorField)
                        .font(.title)
                    }
                    
                    ZStack{
                        ZStack(alignment: .topTrailing){
                            QuickMap(isFocus: self.$isFocus, setDistance: self.$setDistance, errorField: self.$errorField, showAlert: self.$showAlert, activeAlert: self.$activeAlert, distance: self.$distance, isLoading: self.$isLoading, address: self.address, location: self.location, setStart: {
                                self.quickMapViewEnvironment.isStart = $0
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
                    }
                    
                    
                    Spacer()
                    HStack{
                        Button(action: {
                            if self.setDistance != "" && (self.distance > Int(self.setDistance) ?? 0){
                                if (self.quickMapViewEnvironment.isStart ?? false) == false{
                                    self.quickMapViewEnvironment.isStart = true
                                    self.isFocus = true
                                }else{
                                    self.quickMapViewEnvironment.isStart = false
                                    self.isFocus = false
                                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                }
                            }else{
                                self.showError = true
                            }
                        }){
                            if (self.quickMapViewEnvironment.isStart ?? false) == false{
                                
                                Text("시작하기")
                                .padding()
                            }else{
                                Text("중지하기")
                                .padding()
                            }
                        }
                    }
                    .alert(isPresented: self.$showError) {
                        return self.defaultAlert(title: "설정된 거리 오류", message: "목적지까지 거리보다 짧은 거리를 적어주세요")
                    }
                    Spacer()
                }
                .onAppear {
                    self.isNavigationBarHidden = false
                }
                .onDisappear {
                    self.quickMapViewEnvironment.isStart = false
                }
            }
            .blur(radius: self.isLoading ? CGFloat(3) : CGFloat(0))
            ActivityIndicator(style: .large, isLoading: self.$isLoading)
        }.onDisappear {
            self.isQuick = false
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
        self.showError = false
    }
}
//
//struct QuickMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        QuickMapView(isNavigationBarHidden: Binding.constant(true), address: "서울")
//    }
//}
