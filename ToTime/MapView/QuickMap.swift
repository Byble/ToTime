//
//  QuickMapView.swift
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

struct QuickMap{
    @EnvironmentObject var QuickMapViewEnvironment: QuickMapViewEnvironment
    
    @Binding var isFocus: Bool
    @Binding var setDistance: String
    @Binding var errorField: String
        
    @Binding var showAlert: Bool
    @Binding var activeAlert: ALERT
    @Binding var distance: Int
    @Binding var isLoading: Bool
    
    let address: String
    let location: CLLocation
    var setStart: (Bool) -> Void
    
    @State var locationManager: CLLocationManager = CLLocationManager()
    @State var locationNotificationScheduler: LocationNotificationScheduler = LocationNotificationScheduler()
    @State var mapView: MKMapView = MKMapView()
}

extension QuickMap: UIViewRepresentable{
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
                
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), span: span)
        self.mapView.setRegion(region, animated: true)
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        let annotation = MarkAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        self.mapView.addAnnotation(annotation)

        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<QuickMap>) {
        
        QuickMapViewEnvironment.didIsStartChange = {
            if self.QuickMapViewEnvironment.isStart!{
                self.scheduleLocationNotification()
            }else{
                self.stopLocationNotification()
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
        var parent: QuickMap
        var isLoading: Binding<Bool>
        
        init(_ parent: QuickMap, loading: Binding<Bool>) {
            self.parent = parent
            self.isLoading = loading
        }
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            if self.parent.isFocus{
                self.parent.isFocus = false
            }
        }
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

            if let _ = locations.first{
                let distance = manager.location!.distance(from: parent.location)
                parent.distance = Int(distance)
                if self.isLoading.wrappedValue{
                    self.isLoading.wrappedValue = false
                }
            }
            
            if (parent.QuickMapViewEnvironment.isStart ?? false) == true{
                if let distance = manager.location?.distance(from: parent.location){
                    
                    let sDis = Int(parent.setDistance) ?? 0

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
