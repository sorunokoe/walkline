//
//  LocationModel.swift
//  MapExample
//
//  Created by Mac on 14.08.17.
//  Copyright © 2017 salgara. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class LocationModel: NSObject {
    
    private var _location: CLLocation!
    private var _date: String!
    private var _time: String!
    
    var location: CLLocation!{
        set{
            _location = newValue
        }
        get{
            return _location
        }
    }
    var date: String!{
        set{
            _date = newValue
        }
        get{
            return _date
        }
    }
    var time: String!{
        set{
            _time = newValue
        }
        get{
            return _time
        }
    }
    
    
    
    
    
    
}

