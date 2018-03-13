//
//  UserCell.swift
//  WalkLine
//
//  Created by Mac on 26.09.17.
//  Copyright © 2017 salgara. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {

    var user: UserModel!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var noBtn: UIButton!
    @IBOutlet weak var yesBtn: UIButton!
    //Firebase Reference
    var ref: DatabaseReference!
    
    weak var delegate: MyCustomCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ref = Database.database().reference()
    }
    
    @IBAction func actionNo(_ sender: Any) {
        self.ref.child("users").child(self.user.uid).child("requests").child(myUid).setValue(["status": "denied","phone": myPhone,"uid": myUid])
        self.ref.child("users").child(myUid).child("responses").child(self.user.uid).setValue(["status": "denied","phone": self.user.phone, "uid": self.user.uid])
        delegate?.fetchRequests()
    }
    @IBAction func actionYes(_ sender: Any) {
        self.ref.child("users").child(self.user.uid).child("requests").child(myUid).setValue(["status": "yes","phone": myPhone,"uid": myUid])
        self.ref.child("users").child(myUid).child("responses").child(self.user.uid).setValue(["status": "yes","phone": self.user.phone, "uid": self.user.uid])
        delegate?.fetchRequests()
    }
    
    func initData(user: UserModel, status: String){
        self.user = user
        if user.name != nil{
            if user.name.count > 3{
                nameText.text = user.name
            }else{
                nameText.text = user.phone
            }
        }else{
            nameText.text = user.phone
        }
        if(status=="response"){
            self.noBtn.isHidden = true
            self.yesBtn.isHidden = true
        }else{
            self.noBtn.isHidden = false
            self.yesBtn.isHidden = false
        }
    }
    
}
// use a class protocol for delegates so weak properties can be used
protocol MyCustomCellDelegate: class {
    func fetchRequests()
}
