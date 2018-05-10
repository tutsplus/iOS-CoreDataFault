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
    
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SegueListViewController {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            // Fetch List
            let list = self.fetchedResultsController.object(at: indexPath) as! List
            
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
            let listViewController = segue.destination as! ListViewController
            
            // Configure View Controller
            listViewController.list = list
            
        } else if segue.identifier == SegueItemsViewController {
            // Fetch Destination View Controller
            let itemsViewController = segue.destination as! ItemsViewController
            
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifierListCell, for: indexPath as IndexPath)
        
        // Configure Table View Cell
        configureCell(cell: cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        // Fetch List
        let list = fetchedResultsController.object(at: indexPath) as! List
        
        // Update Cell
        cell.textLabel!.text = list.name
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true

    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
            // Fetch List
            let list = fetchedResultsController.object(at: indexPath) as! List
            
            // Delete List
            managedObjectContext.delete(list)
            
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // MARK: -
    // MARK: Fetched Results Controller Delegate Methods
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()

    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath {
                if let cell = tableView.cellForRow(at: indexPath) {
                    configureCell(cell: cell, atIndexPath: indexPath)
                }
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath as IndexPath], with: .fade)
            }
            break;
            
        }
    }

    // MARK: -
    // MARK: Actions
    @IBAction func addList(_ sender: UIBarButtonItem) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "List", in: managedObjectContext)
        
        // Initialize List
        let list = List(entity: entityDescription!, insertInto: managedObjectContext)
        
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
