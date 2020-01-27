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
    @Binding var setDistance: Double
    @Binding var errorField: String
        
    @Binding var showAlert: Bool
    @Binding var activeAlert: ALERT
    @Binding var isLoading: Bool
    
    var address: String
    var setStart: (Bool) -> Void
    
    @State var locationManager: CLLocationManager = CLLocationManager()
    @State var locationNotificationScheduler: LocationNotificationScheduler = LocationNotificationScheduler()
    @State var mapView: MKMapView = MKMapView()
    
    @State var isLocationSet: Bool = false
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
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<HomeMap>) {
        
        homeMapViewEnvironment.didIsStartChange = {
            if self.homeMapViewEnvironment.isStart!{
                if self.isLocationSet{
                    self.scheduleLocationNotification()
                }else{
                    self.setStart(false)
                }
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

        // Google Key
        let key : String = "Private Key"
        let postParameters:[String: Any] = [ "address": address, "key":key]
        let url : String = "https://maps.googleapis.com/maps/api/geocode/json"

        Alamofire.request(url, method: .get, parameters: postParameters, encoding: URLEncoding.default, headers: nil).responseJSON {  response in

            if let receivedResults = response.result.value
            {
                let json = JSON(receivedResults)
                guard "OK" == json["status"] else{
                    return
                }
                let lat = json["results"][0]["geometry"]["location"]["lat"].doubleValue
                let lon = json["results"][0]["geometry"]["location"]["lng"].doubleValue
                let loc = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                completion(loc)
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
            if (parent.homeMapViewEnvironment.isStart ?? false) == true{
                if let distance = manager.location?.distance(from: parent.location){
                    self.parent.errorField = "남은 거리  \(Int(distance) < Int(parent.setDistance) ? Int(parent.setDistance) : Int(distance))m"
                    if distance < parent.setDistance{
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

struct HomeMap_Previews: PreviewProvider {
    static var previews: some View {
        HomeMap(location: Binding.constant(CLLocation(latitude: 0.0, longitude: 0.0)), isLoc: false, isChange: Binding.constant(false), isFocus: Binding.constant(false), setDistance: Binding.constant(100), errorField: Binding.constant(""), showAlert: Binding.constant(false), activeAlert: Binding.constant(ALERT.None), isLoading: Binding.constant(false), address: "", setStart: {_ in })
    }
}
