//
//  AddMarkMapView.swift
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


struct AddMarkMap{
    @Binding var location: CLLocation
    var isLoc: Bool
    
    @Binding var isChange: Bool
    
    @Binding var isFocus: Bool
    @Binding var errorField: String
        
    @Binding var isLoading: Bool
    @Binding var setAddress: String
    
    let address: String
    
    @State var locationManager: CLLocationManager = CLLocationManager()

    @State var mapView: MKMapView = MKMapView()
    
    @State var isLocationSet: Bool = false
}

extension AddMarkMap: UIViewRepresentable{
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
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<AddMarkMap>) {
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
                self.setAddress = json["results"][0]["formatted_address"].stringValue
                self.errorField = json["results"][0]["formatted_address"].stringValue
                completion(loc)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, loading: $isLoading)
    }
    
    // Mark - Coorinator
    final class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate{
        var parent: AddMarkMap

        var area:String = ""
        var locality:String = ""
        var fare:String = ""
        var isLoading: Binding<Bool>
        
        init(_ parent: AddMarkMap, loading: Binding<Bool>) {
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
                                    self.parent.setAddress = "\(self.area) \(self.locality) \(self.fare)"
                                    self.parent.errorField = "\(self.area) \(self.locality) \(self.fare)"
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
        }
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to find user's location: \(error.localizedDescription)")
        }
    }
    /// - Coordinator
}

struct AddMarkMap_Previews: PreviewProvider {
    static var previews: some View {
        AddMarkMap(location: Binding.constant(CLLocation(latitude: 0.0, longitude: 0.0)), isLoc: false, isChange: Binding.constant(false), isFocus: Binding.constant(false), errorField: Binding.constant(""), isLoading: Binding.constant(false), setAddress: Binding.constant(""), address: "")
    }
}
