//
//  TableViewController.swift
//  ToDo-Realm
//
//  Created by kamilcal on 13.12.2022.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TableViewController: UITableViewController {
    
    var button = UIAlertController()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var data: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        tableView.rowHeight = 80.0
        
    }
    //    MARK: - didAddBarButtonItemTapped
    @IBAction func didAddBarButtonItemTapped(_ sender: UIBarButtonItem) {
        presentAddAlert()
    }
    func presentAddAlert() {
        presentAlert(title: "Add New Element",
                     message: nil,
                     defaultButtonTitle: "Add",
                     cancelButtonTitle: "Cancel",
                     isTextFieldAvaible: true,
                     defaultButtonHandler: { _ in
            
            let text = self.button.textFields?.first?.text
            if text != "" {
                
                  if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write{
                            let newItem = Item()
                            newItem.setValue(text, forKey: "title")
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        }
                    } catch {
                        print("Error saving new items, \(error)")
                    }
                    self.tableView.reloadData()
                }
            } else {
                self.presentWarningAlert()
            }
        })
        }


        //MARK: - didRemoveBarButtonItemTapped
        
    @IBAction func didRemoveBarButtonItemTapped(_ sender: UIBarButtonItem) {
        presentAlert(title: "Notification",
                     message: "Are you sure you want to delete all items in the list?",
                     defaultButtonTitle: "Yes",
                     cancelButtonTitle: "Cancel") { _ in

        let realm = try! Realm()
               try! realm.write {
                   realm.delete(self.data!)
               }
            self.tableView.reloadData()
        }
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        if let item = data?[indexPath.row]{
            cell.textLabel?.text = item.value(forKey: "title") as? String
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(data!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            cell.accessoryType = item.done ? .checkmark : .none
        }
        else {
            cell.textLabel?.text = "No Items Added"
        }
       
        return cell
        
    }
    
    //    MARK: -UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let item = data?[indexPath.row] {
            do {
                try realm.write{
                    item.done = !item.done
                }
            } catch {
                print("error saving done status \(error)")
            }
        }
    
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
       
    //    MARK: - presentAlert&presentWarningAlert
    
    func presentWarningAlert() {
        
        presentAlert(title: "Notification", message: "You cannot add an empty element to the list.", cancelButtonTitle: "Done")
    }
    
    func presentAlert(title: String?,
                      message: String?,
                      preferredStyle: UIAlertController.Style = .alert,
                      defaultButtonTitle: String? = nil,
                      cancelButtonTitle: String?,
                      isTextFieldAvaible: Bool = false,
                      defaultButtonHandler: ((UIAlertAction) -> Void)? = nil){
        
        button = UIAlertController (title: title,
                                    message: message,
                                    preferredStyle: preferredStyle)
        if defaultButtonTitle != nil {
            let defaultButton = UIAlertAction(title: defaultButtonTitle,
                                              style: .default,
                                              handler: defaultButtonHandler)
            button.addAction(defaultButton)
        }
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle,
                                         style: .cancel)
        
        if isTextFieldAvaible {
            button.addTextField()
        }
        button.addAction(cancelButton)
        present(button, animated: true)
    }
    
    //    MARK: -loadItems
    

                 func loadItems() {
        
        data = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }

    //    MARK: - Swipe Actions
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteActions = UIContextualAction(style: .normal,
                                               title: "Delete") { _, _, _ in
            let realm = try! Realm()
               try! realm.write {
                   realm.delete((self.data?[indexPath.row])!)
               }
            self.tableView.reloadData()

        }

        deleteActions.backgroundColor = .systemRed

        let config = UISwipeActionsConfiguration(actions: [deleteActions])
        return config
    }
    
}
//    MARK: - Search Bar Methods

extension TableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        data = data?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchBar.text?.count == 0 {
        loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    
}






