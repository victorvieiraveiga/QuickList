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
import TableFlip
import BLTNBoard


class TodoListViewController: SwipeTableViewController  {

    @IBOutlet weak var searchBar: UISearchBar!

    var todoItems: Results<Item>?
    let realm = try! Realm()
    var dateDeadLine : Date = Date()
    
    var textField = UITextField()
    var textFieldDate = UITextField()
    let myDatePicker = UIDatePicker()
    var dateSelect : Date? = nil
    
    var selectCategory : Category? {
        didSet {
            loadItens()
        }
    }
    

    let context = (UIApplication.shared.delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
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
                tableView.reloadData(with: .simple(duration: 0.80, direction: .rotation3D(type: .daredevil), constantDelay: 0.1))
                
            }
        }
    }
    
//    func takeTaskOfDay () -> String{
//        var cat = "" //todoItems![0].parentCategory[0].name
//        
//        var task = "" //"\(cat) - \(todoItems![0].title) \n"
//        
//        for t in todoItems!{
//            var i = 0
//            guard let dateTask = t.dateCreated else {return ""}
//            
//            if (dateFormat(d: dateTask) == dateFormat(d: Date()) ) {
//                if cat != t.parentCategory[i].name {
//                    task =  "\(cat) - \(task + t.title) \n"
//                } else {
//                    task =  "\(task + t.title) \n"
//                }
//            }
//            cat = t.parentCategory[i].name
//            i = i + 1
//        }
//        
//        return task
//    }
    
  //  let conteudo = "<p> <font face='Avenir'> <h3>\(celulaNome) </h3> <b> Data: </b> \(dataString) <br/>  <b>Participantes: </b> \(participantesString) <br/> <b> Observação: </b> \(obs) </p>"
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
        
            cell.textLabel?.text = item.title
            
            if item.dateCreated != nil  {
                if formataData(d: item.dateCreated!) < formataData(d: Date()) {
                    if item.done == false {
                        cell.detailTextLabel?.text = "DeadLine \(dateFormat(d: item.dateCreated!)) ##### Late #####"
                    } else {
                        cell.detailTextLabel?.text = "DeadLine \(dateFormat(d: item.dateCreated!))"
                    }
                   
                } else {
                    cell.detailTextLabel?.text = "DeadLine \(dateFormat(d: item.dateCreated!))"
                }
            } else {
                cell.detailTextLabel?.isHidden = true
            }
         
           
            
            //add contrast color
            if let color = UIColor(hexString: selectCategory!.color)?.darken(byPercentage:CGFloat(indexPath.row)/CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        
                cell.detailTextLabel?.textColor = ContrastColorOf(color, returnFlat: true)
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
       // tableView.animate(animation: .top(duration: 0.8))
    }

    //MARK: - Add New Itens
  //  @available(iOS 14.0, *)
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        self.dateSelect = nil
        let alert = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)

            let action = UIAlertAction(title: "Add Item", style: .default) { (action) in

            if let currentCategory = self.selectCategory {

                do {
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = self.textField.text!
                        
                        if self.dateSelect != nil {
                            newItem.dateCreated = self.dateSelect
                        } else {
                            newItem.dateCreated = Date()
                        }
                       
                        currentCategory.items.append(newItem)

                    }
                } catch  {
                    print ("Error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            self.textField = alertTextField
        }
     
           alert.addTextField { (alertTextField) in
  
            self.myDatePicker.timeZone = .current
            self.myDatePicker.minimumDate = Date()
            self.myDatePicker.preferredDatePickerStyle = .wheels
            self.myDatePicker.frame = CGRect(x: 10, y: 0, width: 200, height: 200)
            self.myDatePicker.datePickerMode = .date
          
            alertTextField.placeholder = "Optional DeadLine"
            self.textFieldDate = alertTextField
            
            let toolBar = UIToolbar()
                toolBar.sizeToFit()

            self.textFieldDate.inputAccessoryView = toolBar
            self.textFieldDate.inputView = self.myDatePicker
            //self.textFieldDate.text = "\(self.myDatePicker.date)"
            
            self.myDatePicker.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControl.Event.valueChanged)

            
            if self.textFieldDate.text != nil {
                self.view.endEditing(true)
            }
        }

         let cancel = UIAlertAction (title: "Cancel", style: .cancel) { (cancel) in
            print ("Cancel")
        }

        alert.addAction(action)
        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
        
        
    }
    @objc func datePickerValueChanged(sender:UIDatePicker) {
          
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateFormatter.timeStyle = DateFormatter.Style.none

        if sender.date != nil {
            self.textFieldDate.text = dateFormat(d: sender.date)
            self.dateSelect = sender.date
        } else {
            //self.textFieldDate.text = dateFormat(d: sender.date)
            self.dateSelect = Date()
        }
       
        self.view.endEditing(true)
        }
    
    func dateFormat (d: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        let now = df.string(from: d)
        return now
    }
//
//    func stringDate (s: String) -> Date{
//        let dateFormatterUK = DateFormatter()
//        dateFormatterUK.dateFormat = "dd-MM-yyyy hh:mm:ss"
//        guard let date = dateFormatterUK.date(from: s) else { return Date() }
//
//        return date
//    }
    
    func formataData (d: Date) -> Date {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        let now = df.string(from: d)
        
        let dateFormatterUK = DateFormatter()
        dateFormatterUK.dateFormat = "dd-MM-yyyy"
        guard let date = dateFormatterUK.date(from: now) else { return Date() }
        
        return date
        
    }
    

    @objc func doSomething(sender: UIDatePicker) {
        self.view.endEditing(true)
    }
    //MARK: - Model Manipulation Methods
    func loadItens () {
        todoItems = selectCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
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
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
        tableView.animate(animation: .top(duration: 0.8))
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItens()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

