//
//  MapController.swift
//  WalkLine
//
//  Created by Mac on 27.09.17.
//  Copyright © 2017 salgara. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    // Another User
    var whoOnMapUser: UserModel!
    
    @IBOutlet weak var nameOfUserOnMap: UILabel!
    var daysOfUserLocation = [String]()
    
    //Firebase Reference
    var ref: DatabaseReference!
    
    @IBOutlet weak var chronicPicker: UIPickerView!
    @IBOutlet weak var timeLocPicker: UIPickerView!
    
    @IBOutlet weak var myMap: MKMapView!
    let locationManager = CLLocationManager()
    
    // Point of user location
    let annotation = MKPointAnnotation()
    
    var whereIsHeTimer: Timer!
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.myMap.showsUserLocation = true;
        self.myMap.showsBuildings = true
        self.myMap.mapType = MKMapType(rawValue: 0)!
        self.myMap.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        //startReceivingSignificantLocationChanges()
        
        self.chronicPicker.delegate = self
        self.chronicPicker.dataSource = self
        
        self.timeLocPicker.delegate = self
        self.timeLocPicker.dataSource = self
        
        
        ref = Database.database().reference()
        
        self.startTimer()
        
        self.daysOfUserLocation.append("Последнее")
        
        self.timeLocPicker.isHidden = true
        if self.whoOnMapUser.name != nil{
            self.nameOfUserOnMap.text = self.whoOnMapUser.name
        }
        
        
    }
    
    func startTimer(){
        if whereIsHeTimer == nil {
            whereIsHeTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.updateHisLocation), userInfo: nil, repeats: true)
        }
    }
    func stopTimer() {
        if whereIsHeTimer != nil {
            whereIsHeTimer.invalidate()
            whereIsHeTimer = nil
        }
    }
    
    @objc func updateHisLocation(){
        let user = Auth.auth().currentUser
        if let user = user {
            if whoOnMapUser.uid != user.uid{
                ref.child("users").child(whoOnMapUser.uid!).child("myCurrentLocation").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dict = snapshot.value as? [String: Any]{
                        
                        let userLoc = CLLocation(latitude: (dict["lat"] as? CLLocationDegrees)!, longitude: (dict["lon"] as? CLLocationDegrees)!)
                        self.setPointOnMap(userLocation: userLoc, time: dict["time"] as! String)
                        
                    }
                })
            }
        }
        
    }
    
    
    
    func setPointOnMap(userLocation: CLLocation, time: String){
        
        //RFC3339DateFormatter.timeZone = TimeZone(forSecondsFromGMT: 0)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
        self.myMap.setRegion(region, animated: true)
        self.annotation.coordinate = userLocation.coordinate
        
        let geocoder = CLGeocoder()
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(userLocation, completionHandler: { (placemarks, error) in
            if error == nil{
                var nameOfLocation: String?
                if let general = placemarks?[0].thoroughfare{
                    nameOfLocation = general
                    if let detail = placemarks?[0].subThoroughfare{
                        nameOfLocation! += " "+detail
                    }
                }
                if let contentGeo = nameOfLocation{
                    self.annotation.title = contentGeo
                }
            }
        })
        if self.annotation.title == nil {
            self.annotation.title = time
        }else{
            self.annotation.subtitle = time
        }
        
        self.myMap.addAnnotation(self.annotation)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let user = Auth.auth().currentUser
        if let user = user {
        if whoOnMapUser.uid != user.uid{
            
            ref.child("users").child(whoOnMapUser.uid!).child("myCurrentLocation").observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String: Any]{
                    
                    let userLoc = CLLocation(latitude: (dict["lat"] as? CLLocationDegrees)!, longitude: (dict["lon"] as? CLLocationDegrees)!)
                    self.setPointOnMap(userLocation: userLoc, time: dict["time"] as! String)
                    
                }
            })
            
            ref.child("users").child(whoOnMapUser.uid!).child("chronic").observe(.value, with: { (snapshot) in
                
                if let dict =  snapshot.value as? [String: Any]{
                    
                    
                    for (k,v) in dict{
                        self.daysOfUserLocation.append(k)
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.createChorinc()
                    })
                    
                }
            }, withCancel: nil)
            
        }
        }
        
        
    }
    
    
    var allKeysOfDayLocation: [String] = [String]()
    var dayDict = [String: [LocationModel]]()
    func createChorinc(){
        
        chronicPicker.reloadAllComponents()
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case chronicPicker:
            return self.daysOfUserLocation.count
        case timeLocPicker:
            return self.whoOnMapUser.locations.count
        default:
            return 0
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView {
        case chronicPicker:
            return self.daysOfUserLocation[row]
        case timeLocPicker:
            return self.whoOnMapUser.locations[row].time
        default:
            return ""
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        
        switch pickerView {
        case chronicPicker:
            
            if self.daysOfUserLocation[row] != nil ,self.daysOfUserLocation[row] == "Последнее"{
                self.startTimer()
                updateHisLocation()
                timeLocPicker.isHidden = true
            }else{
                self.stopTimer()
                timeLocPicker.isHidden = false
                self.whoOnMapUser.locations = [LocationModel]()
                ref.child("users").child(whoOnMapUser.uid!).child("chronic").child(self.daysOfUserLocation[row]).observe(.childAdded, with: { (snapshot) in
                    
                    if let dict =  snapshot.value as? [String: Any]{
                        
                        
                        let locationModelObj = LocationModel()
                        
                        if let lat = dict["lat"] as? CLLocationDegrees, let lon = dict["lon"] as? CLLocationDegrees, let time = dict["time"] as? String, let date = dict["date"] as? String{
                            
                            //if lat != nil, lon != nil, time != nil, date != nil{
                                let userLocationFromDB = CLLocation(latitude: lat, longitude: lon)
                                
                                locationModelObj.location = userLocationFromDB
                                locationModelObj.date = date
                                locationModelObj.time = time
                                
                                self.whoOnMapUser.locations.append(locationModelObj)
                            //}
                        }
                        
                        DispatchQueue.main.async(execute: {
                            self.timeLocPicker.selectRow(0, inComponent: 0, animated: true)
                            self.setPointOnMap(userLocation: self.whoOnMapUser.locations[0].location, time: self.whoOnMapUser.locations[0].time)
                            self.timeLocPicker.reloadAllComponents()
                        })
                        
                        
                        
                        
                    }
                }, withCancel: nil)
                
            }
            
            break
            
            
            
        case timeLocPicker:
            self.setPointOnMap(userLocation: whoOnMapUser.locations[row].location, time: whoOnMapUser.locations[row].time)
            break
        default:
            break
        }
        
        
        
        
        
        
    }


}
