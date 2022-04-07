 //
//  eventModel.swift
//  Count Down
//
//  Created by Max Stephenson on 5/15/17.
//  Copyright © 2018 Max Stephenson. All rights reserved.
//

import UIKit
import CoreFoundation

// Global Variables
var eventsArray = [event]()
var pastIndex:Int = 0
var mainViewControllerTapped:Int? = nil
var eventSelected = 0
var deleted = 0
var popoverNeeded:Bool = false
let darkColor = #colorLiteral(red: 0.1370554393, green: 0.1384124238, blue: 0.1384124238, alpha: 1)

// MARK: calculateDaysUntil
func calculateDaysUntil(ofComponent comp: Calendar.Component, referenceDate: Date) -> Int {
	
//	print("Calculating days until...")
	
    let currentCalendar = Calendar.current
	
	let comps: Set<Calendar.Component> = [.year, .month, .day]
	var dComps = currentCalendar.dateComponents(comps, from: Date())
	
	var dateComps = DateComponents()
	dateComps.year = dComps.year
	dateComps.month = dComps.month
	dateComps.day = dComps.day
	dateComps.hour = (((TimeZone.current.secondsFromGMT())/60)/60)
	dateComps.minute = 0
	dateComps.second = 1
	
	let today = currentCalendar.date(from: dateComps)!
	
	//print(dComps.day)
	
	dComps = currentCalendar.dateComponents(comps, from: referenceDate)
	
	dateComps.year = dComps.year
	dateComps.month = dComps.month
	dateComps.day = dComps.day
	dateComps.hour = (((TimeZone.current.secondsFromGMT())/60)/60)
	
	//let event = currentCalendar.date(from: dateComps)!
	
	/*print(dComps.day)
	print(dateComps.day)*/

	//print(referenceDate)
	let rComps: Set<Calendar.Component> = [.year, .month, .day]
	let rdComps = currentCalendar.dateComponents(rComps, from: referenceDate)
	
	var rDateComps = DateComponents()
	rDateComps.year = rdComps.year
	rDateComps.month = rdComps.month
	rDateComps.day = rdComps.day
	rDateComps.hour = (((TimeZone.current.secondsFromGMT())/60)/60)
	rDateComps.minute = 0
	rDateComps.second = 1
	
	let event = currentCalendar.date(from: rDateComps)
	
	/*print(rDateComps.day)
	
	print(referenceDate)
	print(event)
	print(Date())
	print(today)*/
    
    guard let start = currentCalendar.ordinality(of: .hour, in: .era, for: today) else { return 0 }
	guard let end = currentCalendar.ordinality(of: .hour, in: .era, for: event!) else { return 0 }
	
	let GMTOffset = (((TimeZone.current.secondsFromGMT())/60)/60)
	
	/*print("START\t" + String(start))
	print("END\t\t" + String(end))
	print("GMT\t\t" + String(GMTOffset))
	print("MOD24\t" + String((((end + GMTOffset) - start + GMTOffset))))*/
	
	
	/*if ((((end + GMTOffset) - start + GMTOffset)) < 0) {
		print("DIV-1\t" + String((((end + GMTOffset) - (start + GMTOffset))/24)-1))
		return ((((end + GMTOffset) - (start + GMTOffset))/24)-1)
	}*/
	//print("DIV24\t" + String((((end + GMTOffset) - (start + GMTOffset))/24)))
    return (((end + GMTOffset) - (start + GMTOffset))/24)
	
	/*print(end/24)
	print(start/24)
	print((end-start)/24)
	
	return (end - start)/24*/
    
}

// MARK: sortEvents
func sortEvents() {
	
    print("eventModel\tSorting events...")
    
	// If there is nothing in the eventsArray then there is nothing to sort, attempting to sort will crash application
	if eventsArray.count < 1 { return }
    
    // Sort the array from greatest to least
    eventsArray = eventsArray.sorted(by: {$0.eventDate < $1.eventDate})
    
    // Find the index of the first event in the array that is not a negative number
	for i in 0...eventsArray.count - 1 {
		// Will crash if eventsArray.count < 1
		if calculateDaysUntil(ofComponent: .day, referenceDate: eventsArray[i].eventDate) >= 0 {
			pastIndex = i
			break
		}
	}
    
    // Reverse the order of events in the past
    if pastIndex > 0 {
		
        for _ in 0...pastIndex - 1 {
            for j in 0...pastIndex - 1 {
				
				if calculateDaysUntil(ofComponent: .day, referenceDate: eventsArray[j + 1].eventDate) >= 0 { break }
                else if calculateDaysUntil(ofComponent: .day, referenceDate: eventsArray[j].eventDate) < calculateDaysUntil(ofComponent: .day, referenceDate: eventsArray[j + 1].eventDate) {
                    let a = eventsArray[j]
                    let b = eventsArray[j + 1]
                    eventsArray[j] = b
                    eventsArray[j + 1] = a
                }
            }
        }
    }
}

class eventModel: NSObject {

}
