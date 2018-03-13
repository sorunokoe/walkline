//
//  UserModel.swift
//  MapExample
//
//  Created by Mac on 12.08.17.
//  Copyright © 2017 salgara. All rights reserved.
//

import Foundation


class UserModel : NSObject{
    
    private var _name: String!
    private var _uid: String!
    private var _phone: String!
    
    var locations: [LocationModel] = [LocationModel]()
    
    
    /*
     init(name: String, uid: String, phone: String){
     self._name = name
     self._uid = uid
     self._phone = email
     }*/
    
    
    var name: String!{
        set{
            _name=newValue
        }
        get{
            return _name
        }
    }
    
    var uid: String!{
        set{
            _uid=newValue
        }
        get{
            return _uid
        }
    }
    
    var phone: String!{
        set{
            _phone=newValue
        }
        get{
            return _phone
        }
    }
    
    
}

