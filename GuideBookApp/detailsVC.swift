//
//  detailsVC.swift
//  GuideBookApp
//
//  Created by Emre Gemici on 15.08.2022.
//

import UIKit
import CoreData // sonrada kendimiz ekledik

class detailsVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var countryText: UITextField!
    
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPlaces = ""
    var chosenPlacesID : UUID?

    override func viewDidLoad() {
        super.viewDidLoad()

        if chosenPlaces != ""{
            saveButton.isHidden = true
            //coreData dan veri çekeceğim
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest <NSFetchRequestResult>(entityName:"Places")
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "years") as? Int {
                            yearText.text = String(year)
                        }
                        if let country = result.value(forKey: "country") as? String{
                            countryText.text = String(country)
                        }
                        if let city = result.value(forKey: "city") as? String{
                            cityText.text = String(city)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                    
              
                }
            }
            catch {
                
            }

        }
        else{
            saveButton.isEnabled = false
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
            countryText.text = ""
            cityText.text = ""
        }
        
        
        //Recognizers
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardHiding))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true // Kullanıcı görsele tıklayabiliyor mu?
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageGestureRecognizer)
        
        
        
        
    }
    
    @objc func selectImage(){
        let picker =  UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary //kullanıcının resmi nereden çekeceğini gösteren kaynak
        picker.allowsEditing = true //resmin sonradan editlenmesi
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage //seçme işleminden sonra nasıl bir resim vermesi
        saveButton.isEnabled = true // Resim seçildikten sonra Save Buttonu aktif olacak.
        self.dismiss(animated: true,completion: nil)
    }
    //media ile işimiz bitince bu fonksiyon bir dictionary döndürüyor.
    // resim seçildikten sonra ki işlem de hangi resim verilmesi belirleniyor.

    
    
    @IBAction func saveButonClicked(_ sender: Any) {
       
        //context e ulabilmek için appdelegate tanımlamamız gerekir.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // UIApplication Delegate ulaşmış olduk
        let context = appDelegate.persistentContainer.viewContext // buradaki context i kullanabilirim artık.
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        //Attributes
        
        newPlace.setValue(nameText.text!, forKey: "name")
        newPlace.setValue(artistText.text!, forKey: "artist")
        newPlace.setValue(cityText.text!, forKey: "city")
        newPlace.setValue(countryText.text!, forKey: "country")
        
        if let year = Int(yearText.text!){
            newPlace.setValue(year, forKey: "years")
        }
        
        newPlace.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPlace.setValue(data, forKey: "image") // bir görselin dataya çevrilmesi
        
        do{
            try context.save()
            print("success")
        }
        catch{
            print("Error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)  // bu bütün app içerisinde "newData" bir mesaj yollayacaktır.
        self.navigationController?.popViewController(animated: true) //bir önceki viewController a gitmek
    }
    
    @objc func keyboardHiding(){
        view.endEditing(true)
    }
    

    
    
    
  
}
