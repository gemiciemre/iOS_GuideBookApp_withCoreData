//
//  ViewController.swift
//  GuideBookApp
//
//  Created by Emre Gemici on 12.08.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    @IBOutlet var tableView: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedPlace=""
    var selectedPlaceId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) { // viewDidLoad her çalıştığında bu görüntülenecek
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil) // burada izleyici tanımladık ve kullanıdığımız notificationName birebir aynı isimde olması lazım.
        // bu mesajı gördüğünde getData yı çağıracak
    }
    
    
    
    
    @objc func getData(){ //Verileri CoreData dan çekmek
        
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false) // bu kod sayesinde coreData dan çektiği verileri tekrar tekrar göstermeyecektir.  
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchRequest.returnsObjectsAsFaults = false //Cahce den okuma ile ilgili ayar yaparak hızlı okumasını sağlıyoruz.
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        self.nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                }
                
                self.tableView.reloadData() // Yeni bir veri geldiği zaman tableview ın kendini güncelleme durumu
            }
            }
        }catch{
            print("Error")
        }
        
        
        
    }
   
    @objc func addButtonClicked(){
        selectedPlace = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // secilen seceneğin verilerini aktarmış oluyorum.  
        if segue.identifier == "toDetailsVC"
        {
            let destinationVC = segue.destination as! detailsVC
            destinationVC.chosenPlaces = selectedPlace
            destinationVC.chosenPlacesID = selectedPlaceId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlace = nameArray[indexPath.row]
        selectedPlaceId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            
            let idString = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
            let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let id = result.value(forKey: "id") as? UUID {
                            
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do {
                                    try context.save()
                                    
                                } catch {
                                    print("error")
                                }
                                
                                break // aradığımı bulduktan sonra for loop a ihtiyacım olmayacağı için kullanıyorum.
                                
                            }
                            
                        }
                        
                        
                    }
                    
                    
                }
            } catch {
                print("error")
            }
            
            
            
            
        }
    }
    
 
    

    
    

}

