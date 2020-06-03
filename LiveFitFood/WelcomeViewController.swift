//
//  WelcomeViewController.swift
//  LiveFitFood
//
//  Created by Louise Chan on 2020-06-02.
//  Copyright © 2020 Louise Chan. All rights reserved.
//

import UIKit
import CoreData

class WelcomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Variables
    let dbContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var loggedUser: User?
    var mealkits: [Mealkit] = []
    var meals: [Meal] = []
    
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var imgLoggedUser: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // data from database
        imgLoggedUser.image = UIImage(data: loggedUser?.photo as! Data, scale: 1.0)
        lblUsername.text = loggedUser?.email!
        
        // Check if we need to load data from the stock json file
        fetchMealkitAndMeals()
        if mealkits.count == 0 || meals.count == 0 {
            loadJSONDataToSQLite()
        }
    }
    
    // MARK: Helper functions
    func fetchMealkitAndMeals() {
        let requestMK : NSFetchRequest<Mealkit> = Mealkit.fetchRequest()
        let requestM: NSFetchRequest<Meal> = Meal.fetchRequest()
        
        do {
            // store sorted pokemons in the Pokemon array
            mealkits = try dbContext.fetch(requestMK)
            meals = try dbContext.fetch(requestM)
        } catch {
            print("Error reading from database")
            print(error.localizedDescription)
        }
    }
    
    func loadJSONDataToSQLite() {
        
        guard let file = openDefaultFile() else {
            return
        }
        
        do {
            let data = try String(contentsOfFile: file).data(using: .utf8)
            let json = try JSON(data: data!)
            // Organize into a mealkit json array
            let jsonArray = json.array
            print(jsonArray![0])
            for mealkitJSON in jsonArray! {
                
                let mealkit = Mealkit(context: dbContext)
                mealkit.name = mealkitJSON["kitName"].stringValue
                mealkit.desc = mealkitJSON["kitDesc"].stringValue
                mealkit.photo = mealkitJSON["photo"].stringValue
                mealkit.price = mealkitJSON["price"].doubleValue
                
                let mealsJSONArray = mealkitJSON["meals"].array
                for mealJSON in mealsJSONArray! {
                    let meal = Meal(context: dbContext)
                    meal.name = mealJSON["mealName"].stringValue
                    meal.calories = mealJSON["calories"].doubleValue
                    meal.photo = mealJSON["photo"].stringValue
                    
                    // add meal to meal entity if it is not a duplicate
                    meals.append(meal)
                    
                    mealkit.addToMeals(meal)
                }
                // Add mealkit to mealkit entity
                mealkits.append(mealkit)
            }
            
            // Resolve duplicates by merging them into one
            dbContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            try dbContext.save()
            
        } catch {
            print("Error during json migration to sqlite")
            print(error.localizedDescription)
        }
        
        
    }

    func openDefaultFile()-> String? {
        
        guard let file = Bundle.main.path(forResource:"mealkits", ofType:"json") else {
            print("Cannot find file")
            return nil;
        }
        print("File found: \(file.description)")
        return file
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func btnLogoutPressed(_ sender: Any) {
        performSegue(withIdentifier: "loginSegue", sender: self)
    }
    
    // MARK: Table view delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mealkits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "mealkitCell") as? MealkitTableViewCell
        
        if cell == nil {
            cell = MealkitTableViewCell(style: .default, reuseIdentifier: "mealkitCell")
        }
        
        let index = indexPath.row
        let photo = mealkits[index].photo ?? "noimage"
        cell?.imgMealkitPicture.image = UIImage(named: photo)
        cell?.lblMealkitName.text = "\(mealkits[index].name!) Package"
        cell?.lblMealkitDescription.text = mealkits[index].desc
        cell?.lblMealkitPrice.text = "CA$\(String(format: "%.2f",mealkits[index].price))"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }
}
