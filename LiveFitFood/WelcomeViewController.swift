//
//  WelcomeViewController.swift
//  LiveFitFood
//
//  Created by Louise Chan on 2020-06-02.
//  Copyright © 2020 Louise Chan. All rights reserved.
//

import UIKit
import CoreData

class WelcomeViewController: UIViewController {

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
}
