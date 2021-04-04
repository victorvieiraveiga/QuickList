//
//  CategoryViewController.swift
//  TodoList
//
//  Created by Victor Vieira Veiga on 21/10/20.
//  Copyright © 2020 Victor Vieira Veiga. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import TableViewReloadAnimation
import UserNotifications
import GoogleMobileAds


class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories:  Results<Category>?

    private var interstitial: GADInterstitialAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        tableView.rowHeight = 120.0
        tableView.separatorStyle = .none

        if thereTasksToday() == true {
            
            //Nottifications
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge,.alert,.sound]) { (granted, error) in
                if error == nil {
                    print ("permission is granted \(granted)")
                }
            }
            
            //content notifications
            let content = UNMutableNotificationContent()
            content.title = "Voce tem Tarefas Para Hoje"
            content.body = takeTaskOfDay()

            // trigger notificatios
            let date = Date().addingTimeInterval(1 * 60 * 60)
            let dateComponentes = Calendar.current.dateComponents([.year,.month,.day, .hour,.minute, .second], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponentes, repeats: false)

            //request notification
            let uuidString = UUID().uuidString
            let request =  UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

            center.add(request) { (error) in

            }
            
        
        }

        
        let request = GADRequest()
        // ca-app-pub-3940256099942544/1033173712 - TESTE
        //ca-app-pub-6593854542748346/9284448526 - Produção

        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-3940256099942544/1033173712",
                                    request: request,
                          completionHandler: { [self] ad, error in
                            if let error = error {
                              print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                              return
                            }
                            interstitial = ad
                            interstitial?.fullScreenContentDelegate = self
                          }
        )
        
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist.")}
        
        navBar.backgroundColor = UIColor(hexString: "#FFFEFF")
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: HexColor("#8395a7")!]
        
        tableView.reloadData(with: .simple(duration: 0.80, direction: .rotation3D(type: .captainMarvel), constantDelay: 0.1))
       
    }
  
    
    func thereTasksToday () -> Bool {
        
        var there : Bool = false
        
        if categories!.count > 0 {
            if categories![0].items.count > 0 {
                for categoria in categories!{
                    //cat = categoria.name
                    for item in categoria.items {
    
                        
                            if (dateFormat(d: item.dateCreated!) == dateFormat(d: Date()) ) {
                                there = true
                            }
                    }
                }
            } else {
                there = false
            }
        } else {
            there = false
        }
   
        return there
        
    }
    
    func takeTaskOfDay () -> String{
        var cat = ""//categories![0].name //todoItems![0].parentCategory[0].name
        
        var task = ""//"\(cat) - \(categories![0].items[0].title) \n"
      
        
        for categoria in categories!{
            //cat = categoria.name
            for item in categoria.items {
                
                guard let dateTask = item.dateCreated else {return ""}
                
                if (dateFormat(d: dateTask) == dateFormat(d: Date()) ) {
                    if cat != categoria.name {
                        cat = categoria.name
                        task = task + "\n"
                        task = "\(task + categoria.name) - \(item.title), "
                        //task =  "\(task + item.title) \n"
                    } else {
                        task =  "\(task + item.title), "
                    }
                }
            }
        }
        
        return task
    }
    
    func dateFormat (d: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        let now = df.string(from: d)
        return now
    }
    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name 
            
            guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}
            
            cell.backgroundColor = categoryColor
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if interstitial != nil {
          interstitial!.present(fromRootViewController: self)
        } else {
          print("Ad wasn't ready")
        }
        
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectCategory = categories?[indexPath.row]
        }
    }

    
    //MARK: - Add New Cathegories
    @IBAction func addButtonPress(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todo Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
        let newCategory = Category()
        newCategory.name = textField.text!
        newCategory.color = UIColor.randomFlat().hexValue()
 
        
        
        self.save(category: newCategory)
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category "
            textField = alertTextField
        }
        let cancel = UIAlertAction (title: "Cancel", style: .cancel) { (cancel) in
            print ("Cancel")
        }
        
        
        alert.addAction(action)
        alert.addAction(cancel)
        
       
        present(alert, animated: true, completion: nil)
    }
    //MARK: - Data Manipulation Methods
    func save(category: Category) {
        do {
            try realm.write({
                realm.add(category)
            })//context.save()
        } catch  {
            print ("Error saving category \(error)")
        }
        tableView.reloadData(with: .simple(duration: 0.80, direction: .rotation3D(type: .hulk), constantDelay: 0.1))
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    //Mark: - Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch  {
                print("Error deleting category \(error)")
            }
        }
    }
}


extension CategoryViewController: GADFullScreenContentDelegate {
    /// Tells the delegate that the ad failed to present full screen content.
      func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
      }

      /// Tells the delegate that the ad presented full screen content.
      func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
      }

      /// Tells the delegate that the ad dismissed full screen content.
      func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
      }
}
