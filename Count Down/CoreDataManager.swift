//
//  CoreDataManager.swift
//  Count Down
//
//  Created by Max Stephenson on 5/15/17.
//  Copyright © 2018 Max Stephenson. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    
    // Used to access data from CoreData
    private class func getContext() -> NSManagedObjectContext {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //let appDelegate = AppDelegate()
        let myViewContext = appDelegate.persistentContainer.viewContext
        return myViewContext
    }
    
    class func storeObject(event: event) {
        
        event.eventImage = event.eventImage.fixOrientation()
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "StorageEntity", in: context)
        
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        //let imageData = UIImagePNGRepresentation(event.eventImage) as NSData?
        let imageData = UIImageJPEGRepresentation(event.eventImage, 0)
        
        managedObject.setValue(imageData, forKey: "entityImage")
        managedObject.setValue(event.title, forKey: "entityTitle")
        managedObject.setValue(event.eventDate, forKey: "entityDate")
		managedObject.setValue(event.eventColor, forKey: "entityColor")
        print(event.title)
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    class func fetchObject() -> [event] {
        
        var array = [event]()
        let fetchRequest:NSFetchRequest<StorageEntity> = StorageEntity.fetchRequest()
        
        do {
            let fetchResultVar = try getContext().fetch(fetchRequest)
            
            print("loading")
            for item in fetchResultVar {
                if item.entityTitle != nil && item.entityDate != nil && item.entityImage != nil {
                    print(item.entityTitle!)
					array.append(event(titleInit: item.entityTitle!, dateZeroInit: item.entityDate! as Date, imageInit: UIImage(data: (item.entityImage!) as Data)!, colorInit: item.entityColor as! Bool))
                }
            }
        } catch { }
        return array
    }
    
    class func deleteEvent(entity: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StorageEntity")
        let deleteAllReq = NSBatchDeleteRequest(fetchRequest: request)
        do { try getContext().execute(deleteAllReq) }
        catch { print(error) }
    }
}

extension UIImage {
    func fixOrientation() -> UIImage {
        
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        //image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
        
    }
}
