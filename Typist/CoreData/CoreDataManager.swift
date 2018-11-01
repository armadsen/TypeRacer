//
//  CoreDataManager.swift
//  Typist
//
//  Created by Simon Elhoej Steinmejer on 27/09/18.
//  Copyright © 2018 Simon Elhoej Steinmejer. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    func saveContext(context: NSManagedObjectContext = CoreDataManager.shared.mainContext) throws {
        var error: Error?

        context.performAndWait {
            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }

        if let error = error { throw error }
    }

    lazy var container: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "WpmResult")
            container.loadPersistentStores(completionHandler: { (_, error) in

                if let error = error {
                    fatalError("Failed to load persistence store: \(error)")
                }
            })

            container.viewContext.automaticallyMergesChangesFromParent = true

            return container
    }()

    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
}
