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
    var items = [Value]()
    
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        
        // Delegate
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        fetchedResultsController.delegate = self
        
        // Get items
        guard fetchedResultsController.fetchedObjects != nil else {
            print("Core Data is empty.")
            
            // Get data from localhost
            self.receiveData()
            
            return
        }
        
        items = fetchedResultsController.fetchedObjects as! [Value]
    }
    
    
    // MARK: - Custom Functions
    func receiveData() {
        
        Alamofire.request(.GET, "http://localhost:8080/api/items", parameters: nil).responseArray(Value.self) { (response) in
            switch response.result {
            case .Success(let item):
                print("item = \(item)")
                self.items = item
                self.tableView.reloadData()
                
            case .Failure(let error):
                print("Error = \(error)")
            }
        }
        
        
        //
        //
        //        Alamofire.request(.GET, "http://localhost:8080/api/items").responseJSON { response in
        //            //let jsonValue = response.result.value!
        //            let json = JSON(data: response.data!)
        //
        //            do {
        //                //let jsonValue = try NSJSONSerialization.JSONObjectWithData(response.data!, options: .AllowFragments)
        //
        //                let itemms = [Item].fromJSONArray(json.rawArray)
        //
        //                //print(repoOwners)
        //                //print(jsonValue)
        //            } catch {
        //                print(error)
        //            }
        //
        //        }
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