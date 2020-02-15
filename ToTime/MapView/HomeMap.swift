//
//  HomeMapView.swift
//  ToTime
//
//  Created by 김민국 on 2020/01/22.
//  Copyright © 2020 김민국. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON

enum ACTION{
    case Location, Alert
}

struct HomeMap{
    @EnvironmentObject var homeMapViewEnvironment: HomeMapViewEnvironment
    
    @Binding var location: CLLocation
    var isLoc: Bool
    
    @Binding var isChange: Bool
    
    @Binding var isFocus: Bool
    @Binding var setDistance: String
    @Binding var errorField: String
        
    @Binding var showAlert: Bool
    @Binding var activeAlert: ALERT
    @Binding var isLoading: Bool
    @Binding var distance: Int
    @Binding var percentage: Float
    @State var fullDis: Float = 0
    
    var address: String
    var setStart: (Bool) -> Void
    
    @State var locationManager: CLLocationManager = CLLocationManager()
    @State var locationNotificationScheduler: LocationNotificationScheduler = LocationNotificationScheduler()
    @State var mapView: MKMapView = MKMapView()
    
    @State var isLocationSet: Bool = false
    @State var isFullDis = false
}

extension HomeMap: UIViewRepresentable{
    func setupManager(context: Context){
        locationManager.delegate = context.coordinator
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()

        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestLocation()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        self.locationNotificationScheduler.delegate = context.coordinator
        setupManager(context: context)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
                
        if isLoc{
            getAddress(address: address) { (loc) in
                    let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(loc.latitude, loc.longitude), span: span)
                    self.mapView.setRegion(region, animated: true)
                
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    let annotation = MarkAnnotation(coordinate: CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude))
                    self.mapView.addAnnotation(annotation)
                    self.location = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
                    self.isLocationSet = true
                    if self.isLoading{
                        self.isLoading = false
                    }
                }
            }
        return mapView
    }
    //UIViewRepresentableContext<HomeMap>
    func updateUIView(_ uiView: MKMapView, context: Context) {
        homeMapViewEnvironment.didIsOverTimeChange = {
            if self.homeMapViewEnvironment.isOverTime!{
                self.homeMapViewEnvironment.isOverTime = false
                self.showAlert = true
                self.activeAlert = .TimeOut
            }
        }
        homeMapViewEnvironment.didIsStartChange = {
            if self.homeMapViewEnvironment.isStart!{
                if self.isLocationSet{
                    self.scheduleLocationNotification()
                }else{
                    self.setStart(false)
                    self.errorField = ""
                }
            }else{
                self.stopLocationNotification()
                self.errorField = ""
                self.isFullDis = false
            }
        }
        let status = CLLocationManager.authorizationStatus()
        if isFocus{
            if status == .authorizedAlways || status == .authorizedWhenInUse{
                let span = MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
                let region = MKCoordinateRegion(center: uiView.userLocation.coordinate, span: span)
                uiView.setRegion(region, animated: true)
            }
        }
    }

    func getAddress(address:String, completion: @escaping (CLLocationCoordinate2D) -> Void){

        // Google Key //
        let key : String = googleKey
        let postParameters:[String: Any] = [ "address": address, "key":key]
        let url : String = "https://maps.googleapis.com/maps/api/geocode/json"
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 10
        
        manager.request(url, method: .get, parameters: postParameters, encoding: URLEncoding.default, headers: nil).responseJSON {  response in
            switch response.result{
            case .success:
                if let receivedResults = response.result.value
                {
                    let json = JSON(receivedResults)
                    guard "OK" == json["status"] else{
                        self.homeMapViewEnvironment.isOverTime = true
                        return
                    }
                    let lat = json["results"][0]["geometry"]["location"]["lat"].doubleValue
                    let lon = json["results"][0]["geometry"]["location"]["lng"].doubleValue
                    let loc = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    if let loc = self.locationManager.location{
                        self.distance = Int(loc.distance(from: CLLocation(latitude: lat, longitude: lon)))
                    }
                    self.errorField = json["results"][0]["formatted_address"].stringValue
                    completion(loc)
                }
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    if (self.homeMapViewEnvironment.isOverTime ?? false) == false{
                        self.homeMapViewEnvironment.isOverTime = true
                    }
                }
            }
            
            
        }
    }
    func scheduleLocationNotification(){
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
        self.showAlert = true
        self.activeAlert = .Schedule
    }
    func stopLocationNotification(){
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, loading: $isLoading)
    }
    
    // Mark - Coorinator
    final class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate, LocationNotificationSchedulerDelegate{
        var parent: HomeMap

        var area:String = ""
        var locality:String = ""
        var fare:String = ""
        var isLoading: Binding<Bool>
        
        
        init(_ parent: HomeMap, loading: Binding<Bool>) {
            self.parent = parent
            self.isLoading = loading
        }
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            if self.parent.isFocus{
                self.parent.isFocus = false
            }
        }
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            if parent.isChange{
                if !animated{
                    
                    let centerlat = mapView.centerCoordinate.latitude
                    let centerlon = mapView.centerCoordinate.longitude
                                
                    let center = CLLocation(latitude: centerlat, longitude: centerlon)
                                
                    CLGeocoder().reverseGeocodeLocation(center) { (placemark, error) in
                        if error != nil{
                            print("there was error")
                        }else{
                            if let place = placemark?[0]{
                                if place.administrativeArea != nil && place.locality != nil && place.thoroughfare != nil{
                                    mapView.removeAnnotations(mapView.annotations)
                                    self.area = (place.administrativeArea)!
                                    self.locality = (place.locality)!
                                    self.fare = (place.thoroughfare)!
                                    self.parent.address = "\(self.area) \(self.locality) \(self.fare)"
                                    self.parent.errorField = self.parent.address
                                    self.parent.location = center
                                    let annotation = MarkAnnotation(coordinate: center.coordinate)
                                    mapView.addAnnotation(annotation)
                                    self.parent.isLocationSet = true
                                    
                                    let loc = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
                                    
                                    self.parent.distance = Int(loc.distance(from: center))
                                }else{
                                    self.parent.errorField = "위치 조정을 다시 해주세요"
                                }
                            }
                        }
                    }
                }
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if !parent.isLoc{
                if self.isLoading.wrappedValue{
                    if let loc = locations.first{
                        let status = CLLocationManager.authorizationStatus()
                        if status == .authorizedAlways || status == .authorizedWhenInUse{
                            let tmpLocation: CLLocationCoordinate2D = loc.coordinate
                            let span = MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
                            let region = MKCoordinateRegion(center: tmpLocation, span: span)
                            parent.mapView.setRegion(region, animated: true)
                                                
                            if self.isLoading.wrappedValue{
                                self.isLoading.wrappedValue = false
                            }
                        }
                    }
                }
            }

            if (parent.homeMapViewEnvironment.isStart ?? false) == true{
                if !parent.isFullDis{
                    if let dis = manager.location?.distance(from: parent.location){
                        self.parent.fullDis = Float(dis)
                        parent.isFullDis = true
                    }
                }
                if let distance = manager.location?.distance(from: parent.location){
                    let sDis = Int(parent.setDistance) ?? 0
                    self.parent.errorField = ""
                    self.parent.distance = Int(distance)
                    let setDis = self.parent.fullDis-(Float(self.parent.setDistance) ?? 0)
                    let percent = (self.parent.fullDis - Float(distance)) / setDis
                    if percent <= 0{
                        self.parent.percentage = 0
                    }else{
                        self.parent.percentage = percent * 100
                    }
                    
                    if Int(distance) < sDis{
                        parent.setStart(false)
                        if UIApplication.shared.applicationState == .active{
                            parent.activeAlert = .Reach
                            parent.showAlert = true
                        }else{
                            let locInfo = LocationNotificationInfo(notificationId: "reach_notification_id", locationId: "reach_location_id", title: "도착하였습니다.", body: "더 많은 정보를 보려면 클릭", data: ["위치": "지정한 \(parent.address)에서 \(parent.setDistance) 거리인 위치에 도착하였습니다."])
                            parent.locationNotificationScheduler.request(with: locInfo)
                            parent.stopLocationNotification()
                        }
                    }
                }
            }
        }
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to find user's location: \(error.localizedDescription)")
        }
        func locationPermissionDenied() {
            presentSettingsAlert(action: .Location)
        }
        
        func notificationPermissionDenied() {
            presentSettingsAlert(action: .Alert)
        }
        
        func notificationScheduled(error: Error?) {
            if let _ = error {
                parent.activeAlert = .ScheduleError
                self.parent.showAlert = true
            }
        }
        
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {
            if response.notification.request.identifier == "reach_notification_id" {
                
            }
            completionHandler()
        }
        
        private func presentSettingsAlert(action: ACTION) {
            switch action {
            case .Location:
                parent.activeAlert = .LocationSet
            case .Alert:
                parent.activeAlert = .AlertSet
            }
            self.parent.showAlert = true
        }
    }
    /// - Coordinator
}
