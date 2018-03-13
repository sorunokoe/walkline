//
//  ProfileController.swift
//  WalkLine
//
//  Created by Mac on 26.09.17.
//  Copyright © 2017 salgara. All rights reserved.
//

import UIKit
import Firebase

class ProfileController: UIViewController {

    var user: UserModel!
    //Firebase Reference
    var ref: DatabaseReference!
    
    @IBOutlet weak var nameText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.user != nil{
            nameText.text = self.user.name
        }
        ref = Database.database().reference()
        
        //self.navigationItem.title = user.name
        
    }

    @IBAction func sendRequest(_ sender: Any) {
        
            if myUid != nil {
            self.ref.child("users").child(self.user.uid).child("responses").child(myUid).setValue(["status": "no","phone": myPhone,"uid": myUid])
            self.ref.child("users").child(myUid).child("requests").child(self.user.uid).setValue(["status": "sended","phone": self.user.phone, "uid": self.user.uid])
                navigationController?.popViewController(animated: true)
                dismiss(animated: true, completion: nil)
            }
        
    }
    
}
