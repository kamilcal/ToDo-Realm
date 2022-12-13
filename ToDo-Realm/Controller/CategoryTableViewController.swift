//
//  CategoryTableViewController.swift
//  ToDo-Realm
//
//  Created by kamilcal on 13.12.2022.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var button = UIAlertController()
    
    var categoryData: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        navigationController?.navigationBar.backgroundColor = UIColor.white
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")
    //        }
    //        navBar.backgroundColor = UIColor(hexString: "#1D9BF6")
    //    }
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryData?.count ?? 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryData?[indexPath.row].name
        
        if let category = categoryData?[indexPath.row]{
            
            guard let categoryColour = UIColor(hexString: category.colour) else { fatalError() }
            cell.backgroundColor = categoryColour
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
        return cell
        
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "categoryToItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryData?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCategories(category: Category){
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        
        self.tableView.reloadData()
        
    }
    
    func loadCategories() {
        
        categoryData = realm.objects(Category.self)
        
        self.tableView.reloadData()
        
    }
    
    //MARK: - Add New Categories
    
    @IBAction func didAddBarButtonItemTapped(_ sender: UIBarButtonItem) {
        presentAddAlert()
    }
    func presentAddAlert() {
        presentAlert(title: "Add New Category",
                     message: nil,
                     defaultButtonTitle: "Add",
                     cancelButtonTitle: "Cancel",
                     isTextFieldAvaible: true,
                     defaultButtonHandler: { _ in
            
            let text = self.button.textFields?.first?.text
            if text != "" {
                
                
                let newCategory = Category()
                newCategory.setValue(text, forKey: "name")
                newCategory.colour = UIColor.randomFlat().hexValue()
                self.saveCategories(category: newCategory)
                self.loadCategories()
                
            } else {
                self.presentWarningAlert()
            }
        })
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
    //    MARK: - Swipe Actions
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteActions = UIContextualAction(style: .normal,
                                               title: "Delete") { _, _, _ in
            let realm = try! Realm()
            try! realm.write {
                realm.delete((self.categoryData?[indexPath.row])!)
            }
            self.tableView.reloadData()
            
        }
        //        let editActions = UIContextualAction(style: .normal,
        //                                             title: "Edit",
        //                                             handler: { _, _, _ in
        //            self.presentAlert(title: "Edit Elemet",
        //                              message: nil,
        //                              defaultButtonTitle: "Edit",
        //                              cancelButtonTitle: "Cancel",
        //                              isTextFieldAvaible: true,
        //                              defaultButtonHandler: { _ in
        //
        //                let text = self.button.textFields?.first?.text
        //                if text != "" {
        //                    self.categoryData?[indexPath.row].setValue(text, forKey: "name")
        //
        //                    let newCategory = Category()
        //                    newCategory.setValue(text, forKey: "name")
        //                    self.saveCategories(category: newCategory)
        //                    self.tableView.reloadData()
        //                } else {
        //                    self.presentWarningAlert()
        //                }
        //            })
        //        })
        deleteActions.backgroundColor = UIColor.red
        
        let config = UISwipeActionsConfiguration(actions: [deleteActions])
        return config
    }
    
    
}


