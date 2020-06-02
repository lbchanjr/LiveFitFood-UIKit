//
//  WelcomeViewController.swift
//  LiveFitFood
//
//  Created by Louise Chan on 2020-06-02.
//  Copyright © 2020 Louise Chan. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    // MARK: Variables
    let dbContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var loggedUser: User?
    
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var imgLoggedUser: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // data from database
        imgLoggedUser.image = UIImage(data: loggedUser?.photo as! Data, scale: 1.0)
        lblUsername.text = loggedUser?.email!
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
