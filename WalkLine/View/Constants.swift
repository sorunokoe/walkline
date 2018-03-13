//
//  Constants.swift
//  WalkLine
//
//  Created by Mac on 26.09.17.
//  Copyright © 2017 salgara. All rights reserved.
//

import Foundation


var myPhone: String!
var myUid: String!

func getToday() -> String!{
    let dayMonth = DateFormatter()
    dayMonth.locale = Locale(identifier: "ru_RU")
    dayMonth.dateFormat = "yyyy:MM:dd"
    return dayMonth.string(from: NSDate() as Date)
}
