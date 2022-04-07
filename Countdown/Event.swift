//
//  Event.swift
//  Countdown
//
//  Created by Max Stephenson on 4/6/22.
//

import Foundation
import SwiftUI

class event {
    
    var title = "[TITLE NOT SET]"
    var eventDate:Date = Date()
    var eventImage:Image? = nil   // TODO: Provide a default image
    var eventDark:Bool = false // False = White; True = Black
    
    init(title: String, eventDate: Date, eventImage: Image, eventDark: Bool) {
        self.title = title
        self.eventDate = eventDate
        self.eventImage = eventImage
        self.eventDark = eventDark
    }
    
}
