//
//  NSManagedObject+Conveniences.swift
//  Ignited
//
//  Created by Riley Testut on 10/4/15.
//  Copyright © 2015 Riley Testut. All rights reserved.
//

import CoreData

extension NSManagedObject
{
    class var entityName: String
    {
        return NSStringFromClass(self)
    }
    
    class func insertIntoManagedObjectContext(_ managedObjectContext: NSManagedObjectContext) -> Self
    {
        return self.insertIntoManagedObjectContext(managedObjectContext, type: self)
    }
    
    private class func insertIntoManagedObjectContext<T>(_ managedObjectContext: NSManagedObjectContext, type: T.Type) -> T
    {
        let object = NSEntityDescription.insertNewObject(forEntityName: self.entityName, into: managedObjectContext) as! T
        return object
    }
    
    // MARK: - Fetches -
    
    class func rst_fetchRequest() -> NSFetchRequest<NSFetchRequestResult>
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        return fetchRequest
    }
    
    class func instancesInManagedObjectContext<T: NSManagedObject>(_ managedObjectContext: NSManagedObjectContext, type: T.Type) -> [T]
    {
        return self.instancesWithPredicate(nil, inManagedObjectContext: managedObjectContext, type: type)
    }
    
    class func instancesWithPredicate<T: NSManagedObject>(_ predicate: NSPredicate?, inManagedObjectContext managedObjectContext: NSManagedObjectContext, type: T.Type) -> [T]
    {
        let fetchRequest = self.rst_fetchRequest()
        fetchRequest.predicate = predicate
        
        var results: [T] = []
        
        do
        {
            results = try managedObjectContext.fetch(fetchRequest) as! [T]
        }
        catch let error as NSError
        {
            print("Error loading", predicate as Any, error)
        }
        
        return results
    }
    
    // MARK: - Perform -

    func performAndWait<T>(_ block: @escaping () -> T) -> T
    {
        var result: T! = nil

        self.performAndWait {
            result = block()
        }

        return result
    }

    func performAndWait<T>(_ block: @escaping () throws -> T) throws -> T
    {
        var result: Result<T, Error>! = nil

        self.performAndWait {
            result = Result { try block() }
        }

        let value = try result.get()
        return value
    }
}
