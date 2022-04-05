//
//  AddViewController.swift
//  Count Down
//
//  Created by Max Stephenson on 5/15/17.
//  Copyright © 2018 Max Stephenson. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var daysUntilLabel: UILabel!
    @IBOutlet weak var semanticsLabel: UILabel!
	@IBOutlet weak var dimmerView: UIView!
	
    @IBOutlet weak var tableView: UITableView!
    
    // Variables
    let defaultFontSize = 18
    var dateObject = Date()
	var dateObjectRaw = Date()
    var daysUntil:Int = 0
	var colorSwitchState:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
		colorSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
		
		titleField.font = .systemFont(ofSize: 30)
		titleField.adjustsFontSizeToFitWidth = false
		titleField.returnKeyType = UIReturnKeyType.done
        titleField.clearButtonMode = UITextField.ViewMode.whileEditing
		titleField.autocapitalizationType = .words
		
		titleField.borderStyle = .none
		titleField.layer.cornerRadius = 5
		titleField.layer.masksToBounds = true
		let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: titleField.frame.height))
		titleField.leftView = paddingView
        titleField.leftViewMode = UITextField.ViewMode.always
		self.titleField.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2)
		titleField.textColor = UIColor.white
		
		titleField.delegate = self
        
        if mainViewControllerTapped == nil {
			print("Add new view")
            titleField.text = "Event Name"   // Initial Title Value
            dateLabel.text = dateFormatter.string(from: dateObject) // Replace
            daysUntilLabel.text = String(daysUntil)
			colorSwitch.isOn = false
			colorSwitchState = false
			self.dimmerView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.10)
        }
        else if mainViewControllerTapped != nil {
			print("Edit existing view")
			print("eventColor: " + String(eventsArray[mainViewControllerTapped!].eventColor))
            titleField.text = eventsArray[mainViewControllerTapped!].title
            dateLabel.text = dateFormatter.string(from: eventsArray[mainViewControllerTapped!].eventDate)
            daysUntilLabel.text = String((calculateDaysUntil(ofComponent: .day, referenceDate: eventsArray[mainViewControllerTapped!].eventDate)))
            imageView.image = eventsArray[mainViewControllerTapped!].eventImage
            dateObject = eventsArray[mainViewControllerTapped!].eventDate
			
			if (eventsArray[mainViewControllerTapped!].eventColor) {
				// if the event color switch is set to true from tapped event
				print("eventColor IF")
				colorSwitch.isOn = true
				colorSwitchState = true
				titleField.textColor = darkColor
				dateLabel.textColor = darkColor
				daysUntilLabel.textColor = darkColor
				semanticsLabel.textColor = darkColor
				titleField.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2)
				titleField.textColor = darkColor
				self.dimmerView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.10)
			} else {
				print("eventColor ELSE")
				self.dimmerView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.10)
			}
        }
        
        daysUntil = calculateDaysUntil(ofComponent: .day, referenceDate: dateObject)
        
        semanticsLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)    // Rotate label
        if daysUntil == 1 || daysUntil == -1 { semanticsLabel.text = "day" }
        else { semanticsLabel.text = "days" }
        
        // Set up the tableView
        tableView.delegate = self
        tableView.dataSource = self
        if mainViewControllerTapped == nil { tableView.isScrollEnabled = false }
        
        // titleTextField set up
        titleTextField.delegate = self
        titleTextField.returnKeyType = UIReturnKeyType.done
        
        // Date Picker
        datePicker.tag = 10
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        // imageView parameters
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) { }

    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        // Grab whatever is in the textfiled before data is sent off
        getTextField()
        
        // Send gathered data back to the events array
        if mainViewControllerTapped == nil {
			let newEvent:event = event(titleInit: titleField.text!, dateZeroInit: dateObject, imageInit: imageView.image!, colorInit: colorSwitch.isOn)
            eventsArray.append(newEvent)
        } else {
			eventsArray[mainViewControllerTapped!] = event(titleInit: titleField.text!, dateZeroInit: dateObject, imageInit: imageView.image!, colorInit: colorSwitch.isOn)
        }
        
        // Dismiss the view
        self.dismiss(animated: true, completion: nil)
        mainViewControllerTapped = nil
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        // Dismiss the view
        mainViewControllerTapped = nil
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // *** tableView functions ***************
    // Labels for cells
    
    let editTitleLabel = UILabel()          // Cell 0 Section 0
    let titleTextField = UITextField()
	let colorSwitchLabel = UILabel()		// Cell 1 Section 0
	let colorSwitch = UISwitch()
    let datePicker = UIDatePicker()         // Cell 2 Section 0
    let imagePickerButtonLabel = UILabel()  // Cell 3 Section 0
    let deleteButtonLabel = UILabel()       // Cell 0 Section 1
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if mainViewControllerTapped == nil { return 1 }
        else { return 2 }
        
    }
    // Build the tableView interface
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create new cell object (from reused cell if possible)
        let cell = tableView.dequeueReusableCell(withIdentifier: "prototypeCell")!
        
            // Cell 0 Section 0
        if indexPath.section == 0 && indexPath.row == 0 {
            
			// Toggle text color
			colorSwitchLabel.translatesAutoresizingMaskIntoConstraints = false
			colorSwitch.translatesAutoresizingMaskIntoConstraints = false
			
			let leftCSL = NSLayoutConstraint(item: colorSwitchLabel, attribute: .left, relatedBy: .equal, toItem: cell, attribute: .left, multiplier: 1, constant: 15)
			let centerCSL = NSLayoutConstraint(item: colorSwitchLabel, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
			let width = NSLayoutConstraint(item: colorSwitchLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 150)
			
			let rightCS = NSLayoutConstraint(item: colorSwitch, attribute: .right, relatedBy: .equal, toItem: cell, attribute: .right, multiplier: 1, constant: -15)
			let centerCS = NSLayoutConstraint(item: colorSwitch, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
			
			colorSwitchLabel.text = "Dark Text"
			colorSwitchLabel.font = colorSwitchLabel.font.withSize(CGFloat(defaultFontSize))
			
			cell.addSubview(colorSwitchLabel)
			cell.addSubview(colorSwitch)
			cell.addConstraints([leftCSL, centerCSL, rightCS, centerCS, width])
			
			cell.selectionStyle = .none
        }
			
			// Cell 1 Section 0
		else if indexPath.section == 0 && indexPath.row == 1 {
			
			// Create constraints
			datePicker.translatesAutoresizingMaskIntoConstraints = false
			
			let left = NSLayoutConstraint(item: datePicker, attribute: .left, relatedBy: .equal, toItem: cell, attribute: .left, multiplier: 1, constant: 0)
			let right = NSLayoutConstraint(item: datePicker, attribute: .right, relatedBy: .equal, toItem: cell, attribute: .right, multiplier: 1, constant: 0)
			let centerVertical = NSLayoutConstraint(item: datePicker, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
			
			// Set attributes
            datePicker.datePickerMode = UIDatePicker.Mode.date
			if mainViewControllerTapped != nil {
				datePicker.date = eventsArray[mainViewControllerTapped!].eventDate
			}
			
			
			// Add items and constraints to the cell and items
			cell.addSubview(datePicker)
			cell.addConstraints([left, right, centerVertical])
		}
            
            // Cell 2 Section 0
        else if indexPath.section == 0 && indexPath.row == 2 {
            
			// Create constraints
			imagePickerButtonLabel.translatesAutoresizingMaskIntoConstraints = false
			
			let left = NSLayoutConstraint(item: imagePickerButtonLabel, attribute: .left, relatedBy: .equal, toItem: cell, attribute: .left, multiplier: 1, constant: 0)
			let right = NSLayoutConstraint(item: imagePickerButtonLabel, attribute: .right, relatedBy: .equal, toItem: cell, attribute: .right, multiplier: 1, constant: 0)
			let center = NSLayoutConstraint(item: imagePickerButtonLabel, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
			
			// Set attributes
			imagePickerButtonLabel.text = "Choose Image..."
			imagePickerButtonLabel.textAlignment = NSTextAlignment.center
			imagePickerButtonLabel.font = imagePickerButtonLabel.font.withSize(CGFloat(defaultFontSize))
			imagePickerButtonLabel.textColor = #colorLiteral(red: 0.05490196078, green: 0.4666666667, blue: 1, alpha: 1)
			
			// Add items and constraints to the cell and items
			cell.addSubview(imagePickerButtonLabel)
			cell.addConstraints([left, right, center])
            
        }
            
            // Cell 0 Section 1
        else if indexPath.section == 1 && indexPath.row == 0 {
            
            // Create constraints
            deleteButtonLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let left = NSLayoutConstraint(item: deleteButtonLabel, attribute: .left, relatedBy: .equal, toItem: cell, attribute: .left, multiplier: 1, constant: 0)
            let right = NSLayoutConstraint(item: deleteButtonLabel, attribute: .right, relatedBy: .equal, toItem: cell, attribute: .right, multiplier: 1, constant: 0)
            let center = NSLayoutConstraint(item: deleteButtonLabel, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0)
            
            // Set attributes
            deleteButtonLabel.text = "Delete Event"
            deleteButtonLabel.textAlignment = NSTextAlignment.center
            deleteButtonLabel.font = deleteButtonLabel.font.withSize(CGFloat(defaultFontSize))
            deleteButtonLabel.textColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
            
            // Add items and constraints to the cell and items
            cell.addSubview(deleteButtonLabel)
            cell.addConstraints([left, right, center])
            
        }
        
        return cell
    }
    
    // Set the number of rows for each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 3 }
        else { return 1 }
    }
	
	// Row was tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.row == 2 && indexPath.section == 0 {
            
            // "Choose Image..." was tapped
            
            // Present alertController (little slide up list)
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let fromCamera = UIAlertAction(title: "Camera", style: .default, handler: { (UIAlertAction) in
                self.imageFromCamera()
            })
            let fromLibrary = UIAlertAction(title: "Photo Library", style: .default, handler: {
                (UIAlertAction) in
                self.imageFromLibrary()
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(fromCamera)
            alertController.addAction(fromLibrary)
            alertController.addAction(cancelButton)
            
            // Presents alertController
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = self.view.bounds
            }
			
            self.present(alertController, animated: true, completion: nil)
            
            
            // Unhighlight the cell afterwards
            tableView.deselectRow(at: IndexPath.init(row: indexPath.row, section: indexPath.section), animated: true)
        }
        else if indexPath.row == 0 && indexPath.section == 1 {
			
			let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
			
			let delete = UIAlertAction(title: "Delete Event", style: .destructive, handler: { (UIAlertAction) in
				// Delete Event was tapped
				eventsArray.remove(at: mainViewControllerTapped!)
				
				// Track how many items no longer exist so eventsArray.count + deleted will be the number of items sored in CoreData
				deleted += 1
				
				// Dismiss View
				mainViewControllerTapped = nil
				self.dismiss(animated: true, completion: nil)
			})
			let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			
			alertController.addAction(delete)
			alertController.addAction(cancel)
			
			// Presents alertController
			if let popoverController = alertController.popoverPresentationController {
				popoverController.sourceView = self.view
				popoverController.sourceRect = self.view.bounds
			}
			self.present(alertController, animated: true, completion: nil)
			
			// Unhighlight the cell afterwards
			tableView.deselectRow(at: IndexPath.init(row: indexPath.row, section: indexPath.section), animated: true)
        }
    }
    // Set custom row heights
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Cell 1 Section 0
        if indexPath.section == 0 && indexPath.row == 1 {
            return 180
        }
            // Default height
        else { return 44 }
    }
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 1
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 10
	}
	
    // *** end tableView functions ***************
	
	// *** UITextField ***
	
    // Get text and set label (only if textField != blank)
    func getTextField() {
        if let text = titleTextField.text {
            if !text.isEmpty {
                titleField.text = text
            }
        }
    }
    // Dismiss keyboard when return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        getTextField()
        return true
    }
	
	// *** END UITextField ***
    
    // Date Picker
    @objc func dateChanged(sender:UIDatePicker) {
		
		let userCal = Calendar.current
		
		// Remove Time
		let comps: Set<Calendar.Component> = [.year, .month, .day]
		let dComps = userCal.dateComponents(comps, from: datePicker.date)
		var dateComps = DateComponents()
		dateComps.year = dComps.year
		dateComps.month = dComps.month
		dateComps.day = dComps.day
		dateComps.hour = (((TimeZone.current.secondsFromGMT())/60)/60)
		dateComps.minute = 0
		dateComps.second = 1
		
		dateObject = userCal.date(from: dateComps)!
        dateLabel.text = DateFormatter.localizedString(from: datePicker.date, dateStyle: .long, timeStyle: .none)
		daysUntil = calculateDaysUntil(ofComponent: .day, referenceDate: dateObject)
        daysUntilLabel.text = String(daysUntil + 1) // Duct tape and string
		
		// Return Time
		dateObject = datePicker.date
        
    }
    
    // Choose an image
    func imageFromCamera() {
        
        // Check if the device has a camera
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            
            // Device has a camera, now create the image picker controller
            let imagePicker:UIImagePickerController = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func imageFromLibrary() {
        
        // Check if the device has a photo library (access?)
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            // Device has a photo library
            let imagePicker:UIImagePickerController = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    // Called by imageFromLibrary() and imageFromCamera() when they have an image to do something with
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // Dismiss the imagePicker
        self.dismiss(animated: true, completion: nil)
        // Store the image somewhere
        self.imageView.image = info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage
        
    }
	
	
	@objc func switchValueDidChange(_ sender: UISwitch) {
		if (colorSwitchState == true) {
			// Set to false, change fonts to white
			colorSwitchState = false
			updateColor(switchState: colorSwitchState)
		}
		else {
			// Set to true, change fonts to black
			colorSwitchState = true
			updateColor(switchState: colorSwitchState)
		}
	}
	
	func updateColor(switchState: Bool) {
		
		let changeColor = CATransition()
		changeColor.duration = 0.15
		
		CATransaction.begin()
		
		if (switchState == true) {
			CATransaction.setCompletionBlock {
				self.titleField.layer.add(changeColor, forKey: nil)
				self.dateLabel.layer.add(changeColor, forKey: nil)
				self.daysUntilLabel.layer.add(changeColor, forKey: nil)
				self.semanticsLabel.layer.add(changeColor, forKey: nil)
				self.titleField.textColor = darkColor
				self.dateLabel.textColor = darkColor
				self.daysUntilLabel.textColor = darkColor
				self.semanticsLabel.textColor = darkColor
				self.titleField.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2)
				self.dimmerView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.10)
			}
		}
		else if (switchState == false) {
			CATransaction.setCompletionBlock {
				self.titleField.layer.add(changeColor, forKey: nil)
				self.dateLabel.layer.add(changeColor, forKey: nil)
				self.daysUntilLabel.layer.add(changeColor, forKey: nil)
				self.semanticsLabel.layer.add(changeColor, forKey: nil)
				self.titleField.textColor = UIColor.white
				self.dateLabel.textColor = UIColor.white
				self.daysUntilLabel.textColor = UIColor.white
				self.semanticsLabel.textColor = UIColor.white
				self.titleField.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2)
				self.dimmerView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.10)
			}
		}
		CATransaction.commit()
	}
}
