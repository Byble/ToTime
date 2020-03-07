//
//  HomeView.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/19.
//  Copyright © 2020 김민국. All rights reserved.
//

import SwiftUI
import MapKit
import RealmSwift
import Combine

struct HomeView {
    @ObservedObject var homeViewModel = HomeViewModel()
    let homeMapViewEnvironment = HomeMapViewEnvironment()
    let quickMapViewEnvironment = QuickMapViewEnvironment()
    let addMarkMapViewEnvironment = AddMarkMapViewEnvironment()
}

extension HomeView: View{
    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                VStack(alignment: .leading){
                    VStack(alignment: .leading){
                        Text("지번, 도로명, 건물명을\n입력하세요")
                            .font(.system(size: 35))
                            .padding(.top, 20)
                    }
                    .onTapGesture {
                        self.endEditing()
                    }
                    .padding(.leading, 10)
                    .padding(.trailing, 10)


                    HStack(spacing: 5){
                        TextField("입력하세요", text: $homeViewModel.locName)
                            .padding(.all, 15)
                            .background(Color.lightGreyColor)
                            .foregroundColor(Color.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray, lineWidth: 2)
                        )

                        Spacer(minLength: 10)
                        if !homeViewModel.locName.isEmpty{

                            NavigationLink(destination: HomeMapView(isNavigationBarHidden: $homeViewModel.isNavigationBarHidden, isLoc: true, address: homeViewModel.locName).environmentObject(homeMapViewEnvironment)) {
                                Image(systemName: "magnifyingglass").foregroundColor(Color.gray)
                                    .padding(.all, 20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray, lineWidth: 2)
                                )
                                    .background(Color.lightGreyColor)
                            }
                        }
                        NavigationLink(destination: HomeMapView(isNavigationBarHidden: $homeViewModel.isNavigationBarHidden, isLoc: false, address:"").environmentObject(homeMapViewEnvironment)) {
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
                    .padding(.bottom, 30)
                }

                if homeViewModel.isEdit{
                    VStack(alignment: .leading){
                        Text("최근 검색")
                        .font(.system(size: 25))
                        .padding(.trailing, 5)
                        .padding(.leading, 20)
                        List{
                            ForEach(homeViewModel.recentLoc, id: \.self){ loc in
                                Text(loc)
                            }
                        }
                    }
                    .onTapGesture {
                        self.endEditing()
                    }
                }
                else{
                    VStack(alignment: .leading){
                        HStack(alignment: .center){
                            Text("즐겨찾기")
                                .font(.system(size: 25))
                                .padding(.trailing, 5)
                            Button(action: {
                                self.homeViewModel.showAddMark.toggle()
                            }){
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 25))
                                    .foregroundColor(Color.red)
                            }
                            .sheet(isPresented: self.$homeViewModel.showAddMark) {
                                AddMarkView(didAddMark: {
                                    mark in
                                    self.saveData(name: mark.name, latitude: mark.latitude, longitude: mark.longitude, address: mark.address, iconName: mark.iconName)

                                }).environmentObject(self.addMarkMapViewEnvironment)
                                    .onAppear{
                                        self.homeViewModel.isQuickView = true
                                    }
                                    .onDisappear{
                                        self.homeViewModel.isQuickView = false
                                    }
                            }
                            .padding(.trailing, 10)
                        }
                    }
                    .padding(.leading, 20)
                    .onTapGesture {
                        self.endEditing()
                    }

                    VStack(){
                        if homeViewModel.isReady{
                            List{
                                ForEach(homeViewModel.marks){ mark in
                                    NavigationLink(destination: QuickMapView(address: mark.address, location: CLLocation(latitude: mark.latitude, longitude: mark.longitude), isNavigationBarHidden: self.$homeViewModel.isNavigationBarHidden).environmentObject(self.quickMapViewEnvironment)) {
                                        MarkListRow(mark: mark)
                                            .padding(.bottom, 10)
                                    }
                                }
                                .onDelete(perform: delete)
                            }
                        }
                        else{
                            Text("no data")
                        }
                    }
                }
                Spacer()
            }
            .navigationBarTitle("")
            .navigationBarHidden(self.homeViewModel.isNavigationBarHidden)
            .onAppear {
                self.homeViewModel.isNavigationBarHidden = true
                self.homeViewModel.isEdit = false
            }
        }
    }
    
    private func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        self.homeViewModel.isEdit = false        
    }
    
    private func saveData(name: String, latitude: Double, longitude: Double, address: String, iconName: String){
        
        let data = MarkData()
        data.name = name
        data.latitude = latitude
        data.longitude = longitude
        data.address = address
        data.iconName = iconName
        homeViewModel.addMark(obj: data)
    }
    
    private func delete(at offsets: IndexSet){
        if let first = offsets.first{
            homeViewModel.removeMark(at: first)
        }
    }
}
