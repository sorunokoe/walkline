//
//  ContactsCell.swift
//  WalkLine
//
//  Created by Mac on 26.09.17.
//  Copyright © 2017 salgara. All rights reserved.
//

import UIKit

class ContactsCell: UITableViewCell {
    
    @IBOutlet weak var nameText: UILabel!
    
    func initData(user: UserModel){
        
        if user.name != nil{
            if user.name.count > 3{
                nameText.text = user.name
            }else{
                nameText.text = user.phone
            }
        }else{
            nameText.text = user.phone
        }
        
    }
    
}
