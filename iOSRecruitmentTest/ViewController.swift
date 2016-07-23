//
//  ViewController.swift
//  iOSRecruitmentTest
//
//  Created by Bazyli Zygan on 15.06.2016.
//  Copyright © 2016 Snowdog. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import Alamofire_Gloss

class ViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var fetchedResultsController: NSFetchedResultsController?
    var refreshControl: UIRefreshControl!
    var searchPredicate: NSPredicate?

    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        
        // Add UIRefreshControl
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Reloading...")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), forControlEvents: .ValueChanged)
        
        tableView.addSubview(refreshControl)

        // Delegate
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        // Create 
        loadDataFromCoreData()
        
        // Get items
        guard fetchedResultsController?.fetchedObjects?.count > 0 else {
            print("Core Data is empty.")
            
            loadDataFromLocalHost()
            
            return
        }
    }
    
    
    // MARK: - Custom Functions
    func loadDataFromLocalHost() {
        Alamofire.request(.GET, "http://localhost:8080/api/items", parameters: nil).responseArray(Item.self) { (response) in
            switch response.result {
            case .Success:
                // Core Data: manipulate
               dispatch_async(dispatch_get_main_queue()) {
                    // Core Data: add entities
                    CoreDataManager.instance.saveContext()
                
                    self.loadDataFromCoreData()
                }
                
            case .Failure(let error):
                print("Error = \(error)")
            }
        }
    }
    
    func loadDataFromCoreData() {
        if fetchedResultsController == nil {
            fetchedResultsController = CoreDataManager.instance.fetchedResultsController("Item", keyForSort: "id")
            
            // Delegate
            fetchedResultsController!.delegate = self
        }
        
        fetchedResultsController?.fetchRequest.predicate = searchPredicate
        
        do {
            try fetchedResultsController!.performFetch()
            
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }

    func refresh(sender: AnyObject) {
        refreshBegin("Refresh", refreshEnd: { (x: Int) -> () in
            NSURLCache.sharedURLCache().removeAllCachedResponses()
            
            self.loadDataFromLocalHost()
            self.refreshControl.endRefreshing()
        })
    }
    
    func refreshBegin(newtext: String, refreshEnd: (Int) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            print("refreshing")
            
            sleep(2)
            
            dispatch_async(dispatch_get_main_queue()) {
                refreshEnd(0)
            }
        }
    }
}


// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell") as! TableViewCell
        
        cell.item = fetchedResultsController?.objectAtIndexPath(indexPath) as? Item
        
        return cell
    }
}


// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
            searchPredicate = nil
            
            loadDataFromCoreData()
        }
    }
}


// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let attribute = "id"
        let filterValue = searchBar.text

        if let text = filterValue {
            searchPredicate = NSPredicate(format: "%K CONTAINS[c] %@", attribute, text)
        }
        
        loadDataFromCoreData()
        
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchPredicate = nil
            
            loadDataFromCoreData()
            
            // Hide keyboard
            searchBar.performSelector(#selector(resignFirstResponder), withObject: nil, afterDelay: 0.1)
        }
    }
}


// MARK: - NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}