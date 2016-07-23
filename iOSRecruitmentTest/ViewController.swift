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
    
    var fetchedResultsController = CoreDataManager.instance.fetchedResultsController("Item", keyForSort: "id")
    var refreshControl: UIRefreshControl!
    var items = [Item]()
    
    
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
        fetchedResultsController.delegate = self
        
        // Get items
        guard fetchedResultsController.fetchedObjects != nil else {
            print("Core Data is empty.")
            
            // Get data from localhost
            self.receiveDataFromLocalHost()
            
            return
        }
        
        items = fetchedResultsController.fetchedObjects as! [Item]
    }
    
    
    // MARK: - Custom Functions
    func receiveDataFromLocalHost() {
        Alamofire.request(.GET, "http://localhost:8080/api/items", parameters: nil).responseArray(Item.self) { (response) in
            switch response.result {
            case .Success(let item):
                print("item = \(item)")
                self.items = item
                self.tableView.reloadData()
                
            case .Failure(let error):
                print("Error = \(error)")
            }
        }
    }
    
    func refresh(sender: AnyObject) {
        refreshBegin("Refresh", refreshEnd: { (x: Int) -> () in
            self.items = [Item]()
            NSURLCache.sharedURLCache().removeAllCachedResponses()
            
            self.receiveDataFromLocalHost()
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
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell") as! TableViewCell
        
        cell.item = items[indexPath.row]
        
        return cell
    }
}


// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}


// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    
}


// MARK: - NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}