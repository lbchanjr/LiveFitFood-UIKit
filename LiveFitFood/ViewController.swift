//
//  ViewController.swift
//  LiveFitFood
//
//  Created by Louise Chan on 2020-06-01.
//  Copyright © 2020 Louise Chan. All rights reserved.
//

import UIKit
import CoreData
import AVKit
import MobileCoreServices

class ViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // MARK: Variables
    let dbContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var users: [User] = []
    var imagePicker: UIImagePickerController!
    
    // MARK: Outlets
    @IBOutlet weak var swSaveLoginInfo: UISwitch!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var viewSignup: UIView!
    @IBOutlet weak var lblLoginMessage: UILabel!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    
    @IBOutlet weak var txtConfirmPass: UITextField!
    
    @IBOutlet weak var imgUserPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set text field delegates
        txtPassword.delegate = self
        txtEmail.delegate = self
        txtConfirmPass.delegate = self
        txtPhoneNumber.delegate = self
        
        viewSignup.isHidden = true
        lblLoginMessage.text = ""
        
        let defaults = UserDefaults.standard
        let saveLoginStatus = defaults.bool(forKey: "saveLogin")
        swSaveLoginInfo.isOn = saveLoginStatus

        if saveLoginStatus {
            // Load saved username and password
            txtEmail.text = defaults.string(forKey: "saveEmail") ?? ""
            txtPassword.text = defaults.string(forKey: "savePassword") ?? ""
        }
    
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//
//        let defaults = UserDefaults.standard
//        let saveLoginStatus = defaults.bool(forKey: "saveLogin")
//        swSaveLoginInfo.isOn = saveLoginStatus
//
//        if saveLoginStatus {
//            // Load saved username and password
//            txtEmail.text = defaults.string(forKey: "saveEmail") ?? ""
//            txtPassword.text = defaults.string(forKey: "savePassword") ?? ""
//        }
//    }

    // MARK: Actions
    @IBAction func btnLoginPressed(_ sender: Any) {
        
        txtEmail.resignFirstResponder()
        txtPassword.resignFirstResponder()
        
        guard let email = txtEmail.text else {
            return
        }
        
        guard let password = txtPassword.text else {
            return
        }
        
        if email.isEmpty || password.isEmpty {
            lblLoginMessage.text = "Email and Password should not be empty!"
        } else if !isValidEmail(email) {
            lblLoginMessage.text = "Enter a valid email address!"
        } else {
            
            // Fetch all users that are stored in database.
            fetchUser(withEmail: email)
            
            if users.count == 0 {
                print("No users stored or no matching users!")
                txtEmail.isEnabled = false
                viewSignup.isHidden = false
                lblLoginMessage.text = "User does not exist!\nContinue with sign-up."
                btnLogin.isEnabled = false
            } else {
                print("Email \(email) is found in database, checking for password...")
                
                // Compare inputted password with password stored in database.
                if users[0].password == password {
                    print("passwords are a match... logging in")
                    
                    // Segue to main app display
                    segueToMainAppScreen()
                } else {
                    print("Invalid password")
                    lblLoginMessage.text = "Invalid password! Try again."
                }
                
            }
            
        }
    }
    
    @IBAction func btnCancelPressed(_ sender: Any) {
        resetLoginData()
    }
    @IBAction func btnRegisterPressed(_ sender: Any) {
        
        guard let confPasswd = txtConfirmPass.text else {
            return
        }
        
        guard let phone = txtPhoneNumber.text else {
            return
        }
        
        guard let passwd = txtPassword.text else {
            return
        }
        
        // Make sure that phone and password confirmation fields aren't empty
        if confPasswd.isEmpty || phone.isEmpty || passwd.isEmpty {
            lblLoginMessage.text = "Passwords or Phone number should not be empty!"
            return
        }
        
        // Check if passwords are a match
        if confPasswd != passwd {
            lblLoginMessage.text = "Passwords do not match!"
        } else {
            // Check if image is empty
            if let _ = imgUserPhoto.image?.isEqual(UIImage(named: "noimage")) {
                print("No photo was set during user registration")
            }
            
            // Add user to database
            let user = User(context: dbContext)
            user.email = txtEmail.text
            user.password = passwd
            user.phone = phone
            let photoData = imgUserPhoto.image?.jpegData(compressionQuality: 0) as NSData?
            user.photo = photoData
            
            // Add new user to array
            users.append(user)
            
            // save data to sqlite database
            do {
                
                try dbContext.save()
            } catch {
                print("Error adding user to database")
                lblLoginMessage.text = "Error! User can't be added to database"
                return
            }
            
            // Segue to main app display
            print("User was added to database")
            segueToMainAppScreen()
            
            // Reset data
            resetLoginData()

        }
        
    }
    
    @IBAction func userTappedBackground(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func btnChoosePhotoPressed(_ sender: Any) {
        
        // create an instance of the image picker
        imagePicker = UIImagePickerController()
        
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false) {
            print("Photo gallery not available")
            lblLoginMessage.text = "Photo gallery not available!"
            return
        }
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated:true)
    }
    
    @IBAction func btnUseCameraPressed(_ sender: Any) {
        // create an instance of the image picker
        imagePicker = UIImagePickerController()
        
        if (UIImagePickerController.isSourceTypeAvailable(.camera) == false) {
            print("Device does not have a camera")
            
            // Alert user that device does not have a camera.
            // Create alert controller object and setup title and message to show
            let alertBox = UIAlertController(title:"Device has no camera!",
                                             message: "Switching to \"Photos\".",
                                             preferredStyle: .alert);
            
            // Add OK button for user action but don't specify any handler for the action
            alertBox.addAction(
                UIAlertAction(title: "OK", style: .default, handler: { alert in
                    // Call function that will launch "Photos"
                    self.btnChoosePhotoPressed(UIButton())
                    return
                })
            )
            // Show the alert box on top of the view controller
            self.present(alertBox, animated: true)
            
            // Switch to photo gallery
            return
        }
        
        self.imagePicker.sourceType = .camera
        
        self.imagePicker.delegate = self
        
        self.present(self.imagePicker, animated:true)
    }
    
    // MARK: Helper functions
    func fetchUser(withEmail email: String) {
        let request : NSFetchRequest<User> = User.fetchRequest()
        
        // Query for pokemons that are of different type compared to the selected pokemon
        let query = NSPredicate(format: "email == %@", email)
        request.predicate = query
        
        do {
            // store sorted pokemons in the Pokemon array
            users = try dbContext.fetch(request)
            
            if users.count == 0 {
                print("no user with \(email) is available in database")
            }
            else {
                print("user \(email) found.")
            }
        } catch {
            print("Error reading from database")
        }
    }
    
    // Compare if email string is a valid email address
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func resetLoginData() {
        // Clear user inputs, hide sign-up view and re-enable sign-in/sign-up button
        txtPassword.text = ""
        txtEmail.text = ""
        txtEmail.isEnabled = true
        btnLogin.isEnabled = true
        lblLoginMessage.text = ""
        
        // Clear sign-up inputs
        txtConfirmPass.text = ""
        txtPhoneNumber.text = ""
        imgUserPhoto.image = UIImage(named: "noimage")
        
        // Hide sign-up view
        viewSignup.isHidden = true
    }
    
    func segueToMainAppScreen() {
        // Check if we need to save username and password
        let defaults = UserDefaults.standard
        let toggleSaveLogin = swSaveLoginInfo.isOn
        defaults.set(toggleSaveLogin, forKey: "saveLogin")
        if toggleSaveLogin == true {
            defaults.set(txtEmail.text!, forKey: "saveEmail")
            defaults.set(txtPassword.text!, forKey: "savePassword")
        } else {
            defaults.removeObject(forKey: "saveEmail")
            defaults.removeObject(forKey: "savePassword")
        }
        
        // Segue to main app display
        performSegue(withIdentifier: "welcomeSegue", sender: self)
    }
    
    // MARK: Textfield delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let view = segue.destination as! WelcomeViewController
        view.loggedUser = users[0]
    }
    
    // MARK: Image picker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String else {
            print("No photo chosen")
            lblLoginMessage.text = "No photo chosen"
            return
        }
        
        // hide the image picker view
        picker.dismiss(animated: true)
        
        // Check if photo was chosen
        if (mediaType == String(kUTTypeImage)) {
            print("user chose a photo")
            
            // the camera image or chosen is stored in function info parameter
            let photoTakenFromCamera = info[.originalImage] as? UIImage
            imgUserPhoto.image = photoTakenFromCamera
        }
    }
}

