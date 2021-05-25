//
//  CNCoreData.swift
//  Counters
//
//  Created by Javier Cala Uribe on 24/5/21.
//

import Foundation
import CoreData

class CNCoreData {
    
    // MARK: - Properties

    var managedObjectContext: NSManagedObjectContext!

    static let sharedInstance = CNCoreData()
    
    // MARK: - Initialization
    
    fileprivate init() {
        
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = Bundle.main.url(forResource: "CountersDB", withExtension:"momd") else {
            Logger("Error loading model from bundle")
            return
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            Logger("Error initializing mom from")
            return
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex-1]
        
        // The directory the application uses to store the Core Data store file.
        // This code uses a file named "CountersDatav1.sqlite" in the application's documents directory.
        
        let storeURL = docURL.appendingPathComponent("CountersDatav1.sqlite")
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        } catch {
            Logger("Error migrating store: \(error)")
            try! FileManager.default.removeItem(at: storeURL)
        }
    }
    
    // MARK: - Functions
        
    // Get current CNCounters
    func getCNCounters() -> [CNCounters] {
    
        var fetchedObjects  = [CNCounters]()
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
                
        guard let entity = NSEntityDescription.entity(forEntityName: "CNCounters", in:managedObjectContext) else {
            return fetchedObjects
        }
        
        fetchRequest.entity = entity
        
        do {
            if let context = managedObjectContext {
                fetchedObjects = try context.fetch(fetchRequest) as! [CNCounters]
            }
        } catch let error as NSError {
            Logger("CoreData cncounters error: \(error.localizedDescription)")
        }
        
        return fetchedObjects
    }

    // Set CNCounters
    func setCNCounters(_ array:[CNApiCounters]) {
        // Delete local counters
        let context = CNCoreData.sharedInstance.managedObjectContext
        let countersdb = CNCoreData.sharedInstance.getCNCounters()
        for counter in countersdb {
            context?.delete(counter)
        }
        
        for item in array {
            // Init NSManagedObject type CNCounters
            let cnCounter = NSEntityDescription.insertNewObject(forEntityName: "CNCounters", into: CNCoreData.sharedInstance.managedObjectContext)

            // Set values on NSManageObject
            cnCounter.setValue(item.count, forKey: "count")
            cnCounter.setValue(item.id, forKey: "id")
            cnCounter.setValue(item.title, forKey: "title")
        }
        
        // Save CoreData
        do {
            try CNCoreData.sharedInstance.managedObjectContext.save()
        } catch {
            Logger("Couldn't save: \(error)")
        }
    }
    
    // Delete all local data
    func deleteAllLocalData(){
        // Delete local counters
        let context = CNCoreData.sharedInstance.managedObjectContext
        let countersdb = CNCoreData.sharedInstance.getCNCounters()
        for counter in countersdb {
            context?.delete(counter)
        }
        // Save CoreData
        do {
            try CNCoreData.sharedInstance.managedObjectContext.save()
        } catch {
            Logger("Couldn't save: \(error)")
        }
    }
}
