//
//  MealsViewController.swift
//  LiveFitFood
//
//  Created by Louise Chan on 2020-06-03.
//  Copyright © 2020 Louise Chan. All rights reserved.
//

import UIKit

class MealsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var loggedUser: User?
    var mealkit: Mealkit?
    
    @IBOutlet weak var lblMealKitName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = false
        print("Meal details screen")
        print("logged in user: \(loggedUser!.email!)")
        print("mealkit selected: \(mealkit!.name!)")
        
        lblMealKitName.text = "\(mealkit!.name!) Package"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Table view delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mealkit?.meals?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "mealCell") as? MealTableViewCell
        
        if cell == nil {
            cell = MealTableViewCell(style: .default, reuseIdentifier: "mealCell")
        }
        
        let sort = NSSortDescriptor(key: "name", ascending: true)
        let meals = mealkit?.meals?.sortedArray(using: [sort]) as! [Meal]
        
        cell?.imgMealPhoto.image = UIImage(named: meals[indexPath.row].photo!)
        cell?.lblMealName.text = meals[indexPath.row].name!
        cell?.lblMealCalories.text = String(format: "%.1f kCal", meals[indexPath.row].calories)
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let view = segue.destination as! CheckOutViewController
        view.loggedUser = loggedUser
        view.mealkit = mealkit
    }

}
