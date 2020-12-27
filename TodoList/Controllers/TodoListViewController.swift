//
//  ViewController.swift
//  TodoList
//
//  Created by Victor Vieira Veiga on 07/10/20.
//  Copyright © 2020 Victor Vieira Veiga. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController  {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    //let defaults = UserDefaults.standard
    
    var selectCategory : Category? {
        didSet {
            loadItens()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colorHex = selectCategory?.color {
            title = selectCategory?.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist.")}
            
            if let navColor = UIColor(hexString: colorHex) {
                navBar.backgroundColor = navColor
                navBar.tintColor = ContrastColorOf(navColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navColor, returnFlat: true)]
                searchBar.barTintColor = navColor
                
            }
            

        }
    }
    
    //MARK: - Tableview Datasource Methods


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            
            //Ternary operator ==>
            //value = condition ? valueIfTrue : valueIfFalse
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectCategory!.color)?.darken(byPercentage:CGFloat(indexPath.row)/CGFloat(todoItems!.count)) {
            
//                print ("version 1 \(CGFloat(indexPath.row/todoItems!.count))")
//                print ("Version 2 \(CGFloat(indexPath.row)/CGFloat(todoItems!.count))")
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added"
        }
  
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let item = todoItems?[indexPath.row] {
            do {
                try  realm.write {
                    item.done = !item.done
                }
            } catch  {
                print ("Error saving done status \(error)")
            }
            
           
        }
        tableView.reloadData()
    }

    //MARK: - Add New Itens
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        
        
            let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            

            if let currentCategory = self.selectCategory {
                
                do {
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                        
                    }
                } catch  {
                    print ("Error saving new items, \(error)")
                }
            }
                
            self.tableView.reloadData()
//
//        self.itemArray.append(newItem)

        //self.saveItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
       
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Model Manipulation Methods

//    func saveItems () {
//        do {
//            try context.save()
//
//        }catch {
//            print ("Error saving context\(error)")
//        }
//        self.tableView.reloadData()
//    }
    
    func loadItens () {
        todoItems = selectCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.todoItems? [indexPath.row] {
            
            do {
                try realm.write{
                    realm.delete(itemForDeletion)
                }
            } catch  {
                print ("Error deleting item \(error)")
            }
        }
    }
    
    
    
}
//MARK: - Search Bar Methods

extension TodoListViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
        print (Realm.Configuration.defaultConfiguration.fileURL)
        
    }

//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItens(with: request, predicate: predicate)
   


    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItens()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
