//
//  ListsViewController.swift
//  Faulting
//
//  Created by Bart Jacobs on 30/10/15.
//  Copyright © 2015 Envato Tuts+. All rights reserved.
//

import UIKit
import CoreData

class ListsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    let ReuseIdentifierListCell = "ListCell"
    let SegueListViewController = "SegueListViewController"
    let SegueItemsViewController = "SegueItemsViewController"
    
    @IBOutlet weak var tableView: UITableView!
    
    var managedObjectContext: NSManagedObjectContext!
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "List")
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueListViewController {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            // Fetch List
            let list = self.fetchedResultsController.objectAtIndexPath(indexPath) as! List
            
            /*
            print("1: \(list)")
            
            if let items = list.items {
                print("2: \(items)")
                print("3: \(items.count)")
                print("4: \(items)")
                
                if let item = items.anyObject() {
                    print("5: \(item)")
                    print("6: \(item.name)")
                    print("7: \(item)")
                }
            }
            
            print("8: \(list)")
            */
            
            // Fetch Destination View Controller
            let listViewController = segue.destinationViewController as! ListViewController
            
            // Configure View Controller
            listViewController.list = list
            
        } else if segue.identifier == SegueItemsViewController {
            // Fetch Destination View Controller
            let itemsViewController = segue.destinationViewController as! ItemsViewController
            
            // Configure View Controller
            itemsViewController.managedObjectContext = managedObjectContext
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
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifierListCell, forIndexPath: indexPath)
        
        // Configure Table View Cell
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        // Fetch List
        let list = fetchedResultsController.objectAtIndexPath(indexPath) as! List
        
        // Update Cell
        cell.textLabel!.text = list.name
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            // Fetch List
            let list = fetchedResultsController.objectAtIndexPath(indexPath) as! List
            
            // Delete List
            managedObjectContext.deleteObject(list)
            
            do {
                try managedObjectContext.save()
                
            } catch {
                let saveError = error as NSError
                print("\(saveError), \(saveError.userInfo)")
            }
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
    @IBAction func addList(sender: UIBarButtonItem) {
        let entityDescription = NSEntityDescription.entityForName("List", inManagedObjectContext: managedObjectContext)
        
        // Initialize List
        let list = List(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        
        // Configure List
        list.name = "List \(numberOfLists())"
        
        // Save Changes
        do {
            try list.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }
    }
    
    // MARK: -
    // MARK: Helper Methods
    private func numberOfLists() -> Int {
        var result = 0
        
        if let lists = self.fetchedResultsController.fetchedObjects {
            result = lists.count
        }
        
        return result
    }

}
