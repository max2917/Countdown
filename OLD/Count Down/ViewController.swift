//
//  ViewController.swift
//  Count Down
//
//  Created by Max Stephenson on 5/15/17.
//  Copyright © 2018 Max Stephenson. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsBarButtonItem: UIBarButtonItem!
    
    // Variables
    let dateFormatter = DateFormatter()
    var daysUntil:Int = 0   // default value
    
    // MARK: View did load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // UITableView is a subclass of UIScrollView
        // Each cell is a UITableViewCell object
		
		// Number of times app has been opened
		let delegate = UIApplication.shared.delegate as! AppDelegate
		let times = delegate.currentTimesOfOpenApp
		
		print("ViewController\tviewDidLoad\tTIMES OPENED:\t" + String(times))
		
		if (times == 1) {
			// App has never been opened before
			// Create first time default data
			print(eventsArray.count)
			if eventsArray.count == 0 {
                print("ViewController\tviewDidLoad\t\tApp has never been opened. Created events...")
				// If there are no events, create initial default events
				let birthday = event(titleInit: "Hottest Day on Earth", dateZeroInit: Date(timeIntervalSinceReferenceDate: 369273600), imageInit: #imageLiteral(resourceName: "defaultImage1"), colorInit: false)
				let newyears = event(titleInit: "New Years 2019", dateZeroInit: Date(timeIntervalSinceReferenceDate: 568080000), imageInit: #imageLiteral(resourceName: "defaultImage3"), colorInit: false)
				let moonland = event(titleInit: "Moon Landing", dateZeroInit: Date(timeIntervalSinceReferenceDate: -992394240), imageInit: #imageLiteral(resourceName: "defaultImage2"), colorInit: false)
				
				eventsArray.append(birthday)
				eventsArray.append(newyears)
				eventsArray.append(moonland)
				
				CoreDataManager.storeObject(event: eventsArray[0])
				CoreDataManager.storeObject(event: eventsArray[1])
				CoreDataManager.storeObject(event: eventsArray[2])
            }
		}
		else {
			// App has been opened, fetch stored data
			// Load save state
            print("ViewController\tviewDidLoad\t\tloading events...")
			print(eventsArray.count)
			eventsArray = CoreDataManager.fetchObject()
            print(eventsArray.count)
		}
        
        // sort array
        sortEvents()
        
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
		
		// This is what fixed the swipe to delete UI bug ffs
		self.tableView.estimatedRowHeight = 0.1
		self.tableView.estimatedSectionFooterHeight = 0.1
		self.tableView.estimatedSectionHeaderHeight = 0.1
        
    } // viewDidLoad
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        print("ViewController\tviewWillAppear")
        sortEvents()
        tableView.reloadData()
    }
    
    // MARK: TableView Functions
    // *** Required for UITableViewDataSource and UITableCiewDelegate ***
    
    // MARK: numberOfRowsInSection
    // Set number of rows in each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Find out how many events there are in each section
        var future:Int = 0
        var past:Int = 0
        if eventsArray.count > 0 {
            for i in 0...eventsArray.count - 1 {
                if calculateDaysUntil(ofComponent: .day, referenceDate: eventsArray[i].eventDate) >= 0 { future = future + 1 }
                else { past = past + 1 }
            }
        }
//        print("there are " + future + " future events and " + past + " past events")
        if section == 0 { print("ViewController\tnumberOfRowsInSection FUTURE \(future)"); return future }
        else { print("ViewController\tnumberOfRowsInSection PAST \(past)"); return past }
    }
    
    // Set number of sections
    func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    
    // Set section header title
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print("ViewController\ttitleForHeaderInSection \(section)")
        if section == 0 { return "Future Events" }
        else { return "Past Events" }
    }
    
    // MARK: cellForRowAtIndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print(" ***** cellForRowAtIndexPath \(indexPath.row) *****")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "prototypeCell")!
        
        let maybeTitle      = cell.viewWithTag(1) as? UILabel
        let maybeDate       = cell.viewWithTag(2) as? UILabel
        let maybeDays       = cell.viewWithTag(4) as? UILabel
        let maybeDaysUntil  = cell.viewWithTag(3) as? UILabel
        let maybeImage      = cell.viewWithTag(5) as? UIImageView
        let maybeDimmerView	= cell.viewWithTag(6)
        
        var currentIndex = 0
        
        // Calculate days until for this cell
        if indexPath.section == 0 {
            // Events with days remaining >= 0
            daysUntil = calculateDaysUntil(ofComponent: .day, referenceDate: eventsArray[indexPath.row + pastIndex].eventDate)
            currentIndex = indexPath.row + pastIndex
        }
        else {
            // Events with days remaining < 0 
            daysUntil = calculateDaysUntil(ofComponent: .day, referenceDate: eventsArray[indexPath.row].eventDate)
            currentIndex = indexPath.row
        }
        if let label = maybeTitle {
			label.text = eventsArray[currentIndex].title
			if (eventsArray[currentIndex].eventColor == true) { label.textColor = darkColor }
			else { label.textColor = UIColor.white }
		}
        if let label = maybeDate {
			// Localizing...
			label.text = dateFormatter.string(from: eventsArray[currentIndex].eventDate)
			if (eventsArray[currentIndex].eventColor == true) { label.textColor = darkColor }
			else { label.textColor = UIColor.white }
		}
        if let label = maybeDays {
            label.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)    // Rotate label
            if daysUntil > 1 || daysUntil < -1 { label.text = "days" } else if daysUntil == 0 { label.text = "days" } else { label.text = "day" }
			if (eventsArray[currentIndex].eventColor == true) { label.textColor = darkColor }
			else { label.textColor = UIColor.white }
        }
        if let label = maybeDaysUntil {
			label.text = String(daysUntil)
			if (eventsArray[currentIndex].eventColor == true) { label.textColor = darkColor }
			else { label.textColor = UIColor.white }
		}
        if let imageView = maybeImage { imageView.image = eventsArray[currentIndex].eventImage }
		if let dimmerView = maybeDimmerView {
			if (eventsArray[currentIndex].eventColor == true) { dimmerView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.10)
			} else {
				dimmerView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.10)
			}
		}
        
        return cell
        
    }
    
    // Row tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("ViewController\tdidSelectRowAt \(indexPath)")
        
        // Un-highlight the cell afterwards
        tableView.deselectRow(at: IndexPath.init(row: indexPath.row, section: indexPath.section), animated: true)
        
        if indexPath.section == 0 {
            mainViewControllerTapped = indexPath.row + pastIndex
        }
        else {
            mainViewControllerTapped = indexPath.row
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // cell was swipe to deleted
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		print("ViewController\teditingStyle")
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
			
            if indexPath.section == 0 {
                // Future event
                eventsArray.remove(at: indexPath.row + pastIndex)
            }
            else if indexPath.section == 1 {
                // Past event
                eventsArray.remove(at: indexPath.row)
                pastIndex -= 1
            }
			
            deleted += 1
            
            // update the table
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
	
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("ViewController\theightForRowAt")
        return 150
    }
    
    // *** End tableView ***
    
    // MARK: Button Outlet
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBAction func addButtonTapped(_ sender: Any) {
        func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            print("add button prepare for segue")
            mainViewControllerTapped = nil
        }
    }
}
