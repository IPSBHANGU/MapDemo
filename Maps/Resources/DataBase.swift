//
//  DataBase.swift
//  Maps
//
//  Created by Inderpreet Singh on 21/02/24.
//

import Foundation
import CoreData
import UIKit

class DataBase:NSObject {
    
    static let shared = DataBase()
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    func saveCoordinatesCommon(context: NSManagedObjectContext) -> Result<Bool,Error> {
        let managedContext = context
        
        do {
            try managedContext.save()
            return .success(true)
        } catch {
            return .failure(error)
        }
    }
    
    // fetch NSManaged Object returns array of NSManagedObject
    func fetchCoordinatesCommon<T:NSManagedObject>(model:T.Type) -> Result<[T]?, Error> {
        if let context = appDelegate?.persistentContainer.viewContext {
            
            let request = model.fetchRequest()
            do {
                let resultData = try context.fetch(request)
                return .success(resultData as? [T])
            } catch {
                print("Error fetching object: \(error.localizedDescription)")
                return .failure(error)
            }
        }
        return .failure("no data" as! Error)
    }
}
