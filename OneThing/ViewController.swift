//
//  ViewController.swift
//  OneThing
//
//  Created by Sascha Hobbie on 19.02.19.
//  Copyright © 2019 Sascha Hobbie. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var itemArray = [Items]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        
        var itemText = UITextField()
        
        let alert = UIAlertController(title: "Add Item", message: "", preferredStyle: .alert)
        
        let actionInbox = UIAlertAction(title: "Add to Inbox", style: .default) { (action) in
            let newItem = Items(context: self.context)
            newItem.title = itemText.text!
            newItem.doNow = false
            newItem.whichSection?.sectionName = "Eingang"
            self.itemArray.append(newItem)
            self.saveData()
            if self.navigationItem.title == "Inbox" {
            let predicate = NSPredicate(format: "doNow == false")
                self.loadData(with: predicate) }
        
        }
        
        
        let actionDonow = UIAlertAction(title: "Add to Do Now", style: .default) { (action) in
            let newItem = Items(context: self.context)
            newItem.title = itemText.text!
            newItem.doNow = true
            newItem.whichSection?.sectionName = "Eingang"
            self.itemArray.append(newItem)
            self.saveData()
            if self.navigationItem.title == "Do Now" {
            let predicate = NSPredicate(format: "doNow == true")
                self.loadData(with: predicate) }
            
        }
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addTextField { (textItem) in
            textItem.placeholder = "Buy milk..."
            itemText = textItem
            
        }
        
        alert.addAction(actionInbox)
        alert.addAction(actionDonow)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func startButton(_ sender: UIBarButtonItem) {
        switch sender.title {
        case "Do Now":
            sender.title = "Inbox"
            navigationItem.title = "Do Now"
            
            let predicate = NSPredicate(format: "doNow == true")
            loadData(with: predicate)
            
        case "Inbox":
            sender.title = "Do Now"
            let predicate = NSPredicate(format: "doNow == false")
            navigationItem.title = "Inbox"
            loadData(with: predicate)
           
            
        default:
            break
        }
    }
    
    
    
    // MARK: - CRUD Methods
    
    func saveData() {
        
        do {
        try context.save()
        }
        catch {
            print("Error while saving the data: \(error)")
        }
    }
    
    func loadData(with predicate: NSPredicate = NSPredicate(format: "doNow == false")) {
        let request: NSFetchRequest<Items> = Items.fetchRequest()
        request.predicate = predicate
        do {
        itemArray = try context.fetch(request)
        } catch {
            print("Error while loading the data: \(error)")
        }
        tableView.reloadData()
    }
}


// MARK: - Table View Setting
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
            saveData()
            if navigationItem.title == "Inbox" {
            let predicate = NSPredicate(format: "doNow == false")
                loadData(with: predicate)
            } else {
                let predicate = NSPredicate(format: "doNow == true")
                loadData(with: predicate)
            }
        
    }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch itemArray[indexPath.row].doNow {
        case true:
            itemArray[indexPath.row].doNow = false
            saveData()
            let predicate = NSPredicate(format: "doNow == true")
            loadData(with: predicate)
            
      
        default:
            itemArray[indexPath.row].doNow = true
            saveData()
            loadData()
        }
        
    
}
}


//MARK: - Search Bar Setting
extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            self.loadData()
        } else {
            
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            
            self.loadData(with: predicate)
            
            
        }
    }
    
}

