//
//  YardController.swift
//  WalkLine
//
//  Created by Mac on 24.09.17.
//  Copyright © 2017 salgara. All rights reserved.
//

import UIKit
import Firebase
import Contacts
import CoreLocation

class YardController: UIViewController, UITableViewDataSource, UITableViewDelegate, MyCustomCellDelegate, CLLocationManagerDelegate{
    
    var allrequests = [UserModel]()
    var allresponses = [UserModel]()
    //Firebase
    var ref: DatabaseReference!
    //LocationManager
    var locationManager = CLLocationManager()
    
    var userMe = UserModel()

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var toogleReqRes: UISegmentedControl!
    @IBOutlet weak var userTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userID = Auth.auth().currentUser?.uid
        if userID == nil{
            performSelector(inBackground: #selector(logOut(_:)), with: nil)
        }
        
        self.userTable.delegate = self
        self.userTable.dataSource = self
        
        ref = Database.database().reference()
        fetchMe()
        
        // MAP REQUEST
        configureLocationServices()
        //var _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.setMyLocationIntoFirebase), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func changeSegment(_ sender: Any) {
        self.fetchRequests()
        self.userTable.reloadData()
    }
    @IBAction func logOut(_ sender: Any) {
        do{
            try Auth.auth().signOut()
        }catch{
            print("Can't go home")
        }
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.fetchRequests()
    }
    
    
    
    
    // FETCH USER FROM Firebase DB
    func fetchMe(){
        let user = Auth.auth().currentUser
        if let user = user {
            ref.child("users").child(user.uid).child("info").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dict = snapshot.value as? [String: Any]{
                    
                    myUid = dict["uid"] as? String
                    myPhone = dict["phone"] as? String
                    self.userMe.phone = dict["phone"] as? String
                    self.userMe.uid = dict["uid"] as? String
                    let contact = self.findContacts(phone: dict["phone"] as! String)
                    self.userMe.name = contact.givenName+" "+contact.familyName
                    self.spinner.stopAnimating()
                }
                
            })
        }
        
    }
    
    func fetchRequests(){
        self.allrequests.removeAll()
        self.allresponses.removeAll()
        
        let user = Auth.auth().currentUser
        if let user = user {
             ref.child("users").child(user.uid).child("responses").observe(.childAdded, with: { (snapshot) in
                if let dict =  snapshot.value as? [String: Any]{
                    let newuser = UserModel()
                    newuser.phone = dict["phone"] as! String
                    newuser.uid = dict["uid"] as! String
                    let contact = self.findContacts(phone: dict["phone"] as! String)
                    newuser.name = contact.givenName+" "+contact.familyName
                    if dict["status"] as! String == "yes"{
                        self.allresponses.append(newuser)
                    }
                    if dict["status"] as! String == "no"{
                        self.allrequests.append(newuser)
                    }
                    DispatchQueue.main.async(execute: {
                        self.userTable.reloadData()
                    })
                }
            }, withCancel: nil)
            
            ref.child("users").child(user.uid).child("requests").observe(.childAdded, with: { (snapshot) in
                if let dict =  snapshot.value as? [String: Any]{
                    let newuser = UserModel()
                    newuser.phone = dict["phone"] as! String
                    newuser.uid = dict["uid"] as! String
                    let contact = self.findContacts(phone: dict["phone"] as! String)
                    newuser.name = contact.givenName+" "+contact.familyName
                    if dict["status"] as! String == "yes"{
                        self.allresponses.append(newuser)
                    }
                    DispatchQueue.main.async(execute: {
                        self.userTable.reloadData()
                    })
                }
            }, withCancel: nil)
            
            
            
            
        }
    }
    
    
    
    
    
    
    //TABLE CONFIG
    
    @IBAction func meOnMap(_ sender: Any) {
        //if self.userMe != nil{
            performSegue(withIdentifier: "userOnMap", sender: self.userMe)
        //}
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.toogleReqRes.selectedSegmentIndex == 0{
            let whoSelected = self.allresponses[indexPath.row]
            performSegue(withIdentifier: "userOnMap", sender: whoSelected)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dist = segue.destination as? MapController{
            if let data = sender as? UserModel{
                dist.whoOnMapUser = data
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userTable.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        if self.toogleReqRes.selectedSegmentIndex == 0{
            cell.initData(user: self.allresponses[indexPath.row], status: "response")
        }
        if self.toogleReqRes.selectedSegmentIndex == 1{
            cell.initData(user: self.allrequests[indexPath.row], status: "request")
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        // set the delegate
        cell.delegate = self
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.toogleReqRes.selectedSegmentIndex == 0{
            return self.allresponses.count
        }
        if self.toogleReqRes.selectedSegmentIndex == 1{
            return self.allrequests.count
        }
        return 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    
    
    // CONTACTS
    func findContacts (phone: String) -> CNContact{
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),CNContactPhoneNumbersKey] as [Any]
        let fetchRequest = CNContactFetchRequest( keysToFetch: keysToFetch as! [CNKeyDescriptor])
        var foundedContact = CNContact()
        CNContact.localizedString(forKey: CNLabelPhoneNumberiPhone)
        fetchRequest.mutableObjects = false
        fetchRequest.unifyResults = true
        fetchRequest.sortOrder = .userDefault
        
        //let contactStoreID = CNContactStore().defaultContainerIdentifier()
        //print("\(contactStoreID)")
        
        
        do {
            try CNContactStore().enumerateContacts(with: fetchRequest) { ( contact, stop) -> Void in
                
                if contact.phoneNumbers.count > 0 {
                    if phone == (contact.phoneNumbers[0].value).value(forKey: "digits") as! String{
                        foundedContact = contact
                    }
                }
                
            }
        } catch let e as NSError {
            print(e.localizedDescription)
        }
        
        return foundedContact
        
        
        
    }
    
    
    
    
    
    
    
    
    // MAP REQUEST  - LOCATION
    
    
    func configureLocationServices() {
        
        // Request authorization, if needed.
        let authorizationStatus = CLLocationManager.authorizationStatus()
        switch authorizationStatus {
        case .notDetermined:
            self.locationManager.requestAlwaysAuthorization()
            //self.locationManager.requestWhenInUseAuthorization()
            break
        default: break
        }
        
        if !CLLocationManager.locationServicesEnabled() {
            // Location services is not available.
            return
        }
        // Configure and start the service.
        //locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1.0  // In meters.
        locationManager.delegate = self
        
        //locationManager.startUpdatingLocation()
        locationManager.startUpdatingLocation()
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        
        let lastLocation = locations.last!
        self.setMyLocationIntoFirebase(lastLocation: lastLocation)
        
        
        print("Change Location")
        
    }
    
    func setMyLocationIntoFirebase(lastLocation: CLLocation){
        
        let allTime = DateFormatter()
        allTime.locale = Locale(identifier: "ru_RU")
        allTime.dateFormat = "yyyy:MM:dd HH:mm"
        let dayMonth = DateFormatter()
        dayMonth.locale = Locale(identifier: "ru_RU")
        dayMonth.dateFormat = "yyyy:MM:dd"
        let minuteSec = DateFormatter()
        minuteSec.locale = Locale(identifier: "ru_RU")
        minuteSec.dateFormat = "HH:mm"
        let user = Auth.auth().currentUser
        if let user = user {
            self.ref.child("users").child(user.uid).child("myCurrentLocation").setValue(["lat": lastLocation.coordinate.latitude, "lon": lastLocation.coordinate.longitude, "time": minuteSec.string(from: NSDate() as Date)])
            
            self.ref.child("users").child(user.uid).child("chronic").child(dayMonth.string(from: NSDate() as Date)).child(minuteSec.string(from: NSDate() as Date)).setValue(["lat": locationManager.location?.coordinate.latitude as Any, "lon": locationManager.location?.coordinate.longitude as Any, "date": dayMonth.string(from: NSDate() as Date),"time": minuteSec.string(from: NSDate() as Date)])
        }
    }
    
    
    
    
    
    
    
}
