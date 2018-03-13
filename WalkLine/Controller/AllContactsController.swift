//
//  AllContactsController.swift
//  WalkLine
//
//  Created by Mac on 25.09.17.
//  Copyright © 2017 salgara. All rights reserved.
//

import UIKit
import Contacts
import Firebase


class AllContactsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Firebase
    var ref: DatabaseReference!
    // Array of all user
    var allusers = [UserModel]()
    // Data from Contacts
    var contacts = [CNContact]()
    
    @IBOutlet weak var contactsTable: UITableView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.spinner.startAnimating()
        
        self.contactsTable.delegate = self
        self.contactsTable.dataSource = self
        
        // Fetched data from Contacts
        if self.contacts.count == 0{
            self.contacts = findContacts()
        }
        ref = Database.database().reference() 
        //Fetched data from Firebase DB
        fetchUser()
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func update(_ sender: Any) {
        self.contacts = findContacts()
        for contact in self.contacts{
            print((contact.phoneNumbers[0].value).value(forKey: "digits") as! String)
        }
    }
    
    
    func findContacts () -> [CNContact]{
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),CNContactPhoneNumbersKey] as [Any]
        let fetchRequest = CNContactFetchRequest( keysToFetch: keysToFetch as! [CNKeyDescriptor])
        var contacts = [CNContact]()
        CNContact.localizedString(forKey: CNLabelPhoneNumberiPhone)
        fetchRequest.mutableObjects = false
        fetchRequest.unifyResults = true
        fetchRequest.sortOrder = .userDefault
        
        //let contactStoreID = CNContactStore().defaultContainerIdentifier()
        //print("\(contactStoreID)")
        
        
        do {
            
            try CNContactStore().enumerateContacts(with: fetchRequest) { ( contact, stop) -> Void in
                
                if contact.phoneNumbers.count > 0 {
                    contacts.append(contact)
                }
                
            }
        } catch let e as NSError {
            print(e.localizedDescription)
        }
        
        return contacts
        
    }
    
    
    func fetchUser(){
        ref.child("users").observe(.childAdded, with: { (snapshot) in
            if let dict =  snapshot.value as? [String: Any]{
                if let info = dict["info"] as? [String: Any]{
                    let user = Auth.auth().currentUser
                    if let user = user {
                        if info["uid"] as! String != user.uid as! String {
                            let user = UserModel()
                            //print(info["phone"])
                            user.phone = info["phone"] as! String
                            user.uid = info["uid"] as! String
                            //user.setValuesForKeys(info)
                            self.allusers.append(user)  
                        }
                        DispatchQueue.main.async(execute: {
                            self.synchContactsAndUser(allusers: self.allusers)
                        })
                    }
                }
            }
        }, withCancel: nil)
    }
    
    
    func synchContactsAndUser(allusers: [UserModel]){
        for user in allusers{
            for contact in self.contacts{
                //print((contact.phoneNumbers[0].value).value(forKey: "digits") as! String)
                if user.phone == (contact.phoneNumbers[0].value).value(forKey: "digits") as! String{
                    //print(contact.givenName+" "+contact.familyName)
                    user.name = contact.givenName+" "+contact.familyName
                }
            }
        }
        self.contactsTable.reloadData()
        self.spinner.stopAnimating()
    }

    
    
    
    
    
    //TABLE CONFIGS
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "profile", sender: self.allusers[indexPath.row])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ProfileController{
            if let data = sender as? UserModel{
                dest.user = data
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contactsTable.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactsCell
        cell.initData(user: self.allusers[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allusers.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    
    

}
