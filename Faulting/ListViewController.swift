//
//  ListViewController.swift
//  Faulting
//
//  Created by Bart Jacobs on 30/10/15.
//  Copyright © 2015 Envato Tuts+. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    let ReuseIdentifierItemCell = "ItemCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    var list: List!
    
    var managedObjectContext: NSManagedObjectContext {
        get {
            return list.managedObjectContext!
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Item")
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Predicate
        let predicate = NSPredicate(format: "%K == %@", "list", self.list)
        fetchRequest.predicate = predicate
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()

    // MARK: -
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }
    
    // MARK: -
    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifierItemCell, forIndexPath: indexPath)
        
        // Configure Table View Cell
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        // Fetch Item
        let item = fetchedResultsController.objectAtIndexPath(indexPath) as! Item
        
        // Update Cell
        cell.textLabel!.text = item.name
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            // Fetch Item
            let item = fetchedResultsController.objectAtIndexPath(indexPath) as! Item
            
            // Delete Item
            self.managedObjectContext.deleteObject(item)
        }
    }
    
    // MARK: -
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: -
    // MARK: Fetched Results Controller Delegate Methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            if let indexPath = indexPath {
                if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                    configureCell(cell, atIndexPath: indexPath)
                }
            }
            break;
        case .Move:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break;
        }
    }
    
    // MARK: -
    // MARK: Actions
    @IBAction func addItem(sender: UIBarButtonItem) {
        let entityDescription = NSEntityDescription.entityForName("Item", inManagedObjectContext: self.managedObjectContext)
        
        // Initialize Item
        let item = Item(entity: entityDescription!, insertIntoManagedObjectContext: self.managedObjectContext)
        
        // Configure Item
        item.list = self.list
        item.name = "\(list.name!) - Item \(numberOfItems())"
        
        // Save Changes
        do {
            try self.managedObjectContext.save()
        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }
    }
    
    // MARK: -
    // MARK: Helper Methods
    private func numberOfItems() -> Int {
        var result = 0
        
        if let items = self.fetchedResultsController.fetchedObjects {
            result = items.count
        }
        
        return result
    }

}
