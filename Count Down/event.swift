//
//  event.swift
//  Count Down
//
//  Created by Max Stephenson on 5/15/17.
//  Copyright © 2018 Max Stephenson. All rights reserved.
//

import UIKit

class event:NSObject {
    
    var title = "[TITLE]"
    var eventDate:Date = Date()
    var eventImage:UIImage = #imageLiteral(resourceName: "defaultImage3")
	var eventColor:Bool = false // False = White; True = Black
    
	init(titleInit: String, dateZeroInit: Date, imageInit: UIImage, colorInit: Bool) {
        self.title = titleInit
        self.eventDate = dateZeroInit
        self.eventImage = imageInit
		self.eventColor = colorInit
    }
    
}
