//
//  OrderSummaryViewController.swift
//  LiveFitFood
//
//  Created by Louise Chan on 2020-06-03.
//  Copyright © 2020 Louise Chan. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class OrderSummaryViewController: UIViewController, CLLocationManagerDelegate {

    let dbContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var order: Order?
    var loggedUser: User?
    var coupons: [Coupon] = []
    var shakes = 3
    var dateToday: String!
    var timer: Timer?
    var timerMinute = 0
    var timerSecond = 0
    
    // Location manager
    let locationManager = CLLocationManager()
    
    // Note: Shop location coordinate is set to George Brown College since no work address is available for this business
    let SHOP_LOCATION_COORDINATES = CLLocationCoordinate2D(latitude: 43.6761366, longitude: -79.412679)
    // Note: Distance of user before order will be prepared is 100m
    let SHOP_DISTANCE_BEFORE_PREPARATION: CLLocationDistance = 100 // Change back to 100
    // Note: Once order is prepared, a 15 minute timer will commence
    let TIMER_MINUTE_TIMEOUT = 15        // change to 15 when not demo-ing the project
    let TIMER_SECOND_TIMEOUT = 0
    
    @IBOutlet weak var lblOrderStatus: UILabel!
    @IBOutlet weak var lblShakeInstructions: UILabel!
    @IBOutlet weak var lblShakeCounter: UILabel!
    @IBOutlet weak var lblOrderNumber: UILabel!
    
    @IBOutlet weak var lblOrderDate: UILabel!
    
    @IBOutlet weak var lblOrderItem: UILabel!
    
    @IBOutlet weak var lblOrderTotal: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblOrderNumber.text = "\(String(format: "%010u", order!.number))"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMM-dd, hh:mm:ss a"
        
        let formattedDate = dateFormatter.string(from: order!.datetime! as Date)
        lblOrderDate.text = "\(formattedDate)"
        
        lblOrderItem.text = "\(order!.item!.name!) Package"
        lblOrderTotal.text = "\(String(format: "$%.2f", order!.total))"
        shakes = 3
        lblShakeCounter.text = ""
        lblShakeInstructions.isHidden = true
        
        checkLocationServices()
        
        lblOrderStatus.text = "Please start driving towards the store..."
            
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func btnCheckCouponsPressed(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        dateToday = dateFormatter.string(from: Date())
        
        print("Date today is: \(dateToday!)")
        fetchCoupons(on: dateToday)
        
        if coupons.count == 0 {
            lblShakeInstructions.isHidden = false
            shakes = 3
            lblShakeCounter.text = "\(shakes)"
            
        } else {
            showCouponAlert(title: "Sorry!", msg: "You are only allowed to play for a coupon discount once per day. Try again tomorrow.")
        }
    }
    
    func fetchCoupons(on date: String) {
        let request : NSFetchRequest<Coupon> = Coupon.fetchRequest()
        
        // Query for coupons that were generated on specified date for the logged user
        let query = NSPredicate(format: "dateGenerated == %@ AND owner == %@", date, loggedUser!)
        request.predicate = query
        
        do {
            coupons = try dbContext.fetch(request)
        } catch {
            print("Error reading from database")
        }
        
    }
    
    func generateDiscount() -> Double {
        let discountArray = [Int](repeating: 50, count: 5) + [Int](repeating: 10, count: 30) + [Int](repeating: 0, count: 65)
        print("Discount array: \(discountArray)")
        let shuffledArray = discountArray.shuffled()
        print("Shuffled array: \(shuffledArray)")
        
        let randomIndex = Int.random(in: 0...99)
        let randomValue = Double(shuffledArray[randomIndex])
        print("Using index = \(randomIndex) to get \(randomValue)")
        
        return randomValue
    }
    
    func showCouponAlert(title: String, msg: String) {
        let alertBox = UIAlertController(title: title,
                                         message: msg,
                                         preferredStyle: .alert);
        
        // Add OK button for user action but don't specify any handler for the action
        alertBox.addAction(
            UIAlertAction(title: "OK", style: .default, handler: nil)
        )
        
        // Show the alert box on top of the view controller
        self.present(alertBox, animated: true)
    }
    @IBAction func btnHomeNavPressed(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
        
        locationManager.stopUpdatingLocation()
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if lblShakeInstructions.isHidden == false {
                if shakes > 1 {
                    shakes -= 1
                    lblShakeCounter.text = "\(shakes)"
                    return
                }

                print("3 shakes have been detected!")
                lblShakeInstructions.isHidden = true
                lblShakeCounter.text = ""
                getCouponForUser()
                
            }
        }
    }
    
    func getCouponForUser() {
        let discount = generateDiscount()

        let discountInt = Int(discount.rounded())
        let newCoupon = Coupon(context: dbContext)
        print("Coupon discount: \(discountInt)")
        if discountInt != 0 {
            showCouponAlert(title: "Congratulations!", msg: "You have just received a coupon with \(discountInt)% on your next purchase.")
            
            newCoupon.isUsed = false
        } else {
            newCoupon.isUsed = true
            showCouponAlert(title: "Thanks for playing", msg: "Unfortunately, you didn't win any coupon discount")
        }
        
        
        newCoupon.dateGenerated = dateToday
        newCoupon.discount = discount
        
        newCoupon.owner = loggedUser
        newCoupon.appliedTo = nil
        newCoupon.code = Int64(dateToday.hashValue)
        print("Coupon code: \(String(format: "%010u", abs(newCoupon.code))), Discount: \(discount)%")
        do {
            try dbContext.save()
        } catch {
            print("Error saving coupon!")
            print(error.localizedDescription)
        }
        
    }
    
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            showLocationServicesEnableWarning(msg: "Location services needs to be enabled in order for this app to work.")
        }
    }
    
    func showLocationServicesEnableWarning(msg: String) {
        let alertBox = UIAlertController(title:"Warning",
                                         message: msg,
                                         preferredStyle: .alert);
        
        // Add OK button for user action but don't specify any handler for the action
        alertBox.addAction(
            UIAlertAction(title: "OK", style: .default, handler: nil)
        )
        
        // Show the alert box on top of the view controller
        self.present(alertBox, animated: true)
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .denied:
            showLocationServicesEnableWarning(msg: "Please allow Location Services to be enabled for this app. App will not work without this feature.")
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            showLocationServicesEnableWarning(msg: "Location services is restricted.")
            break
        case .authorizedAlways:
            break
        default:
            break
        }
    }
    
    // MARK: Core Location delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Check if the distance between current location and store location is 100m or less
        let distance = location.distance(from: CLLocation(latitude: SHOP_LOCATION_COORDINATES.latitude, longitude: SHOP_LOCATION_COORDINATES.longitude))
        
        if distance <= SHOP_DISTANCE_BEFORE_PREPARATION && lblOrderStatus.text != "Your order is now ready for pickup." {
            
            if timer == nil {
                timerMinute = TIMER_MINUTE_TIMEOUT
                timerSecond = TIMER_SECOND_TIMEOUT
                lblOrderStatus.text = "Preparing your order...\nIt will be ready in \(timerMinute)m \(timerSecond)s"
                showCouponAlert(title: "Order update", msg: "Your order is being prepared. It will be ready within 15 minutes")

                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
                    timer in
                    if self.timerSecond <= 0 {
                        if self.timerMinute <= 0 {
                            // Timer has expired
                            self.timer!.invalidate()
                            self.timer = nil
                            
                            self.showCouponAlert(title: "Order update", msg: "Your order is now ready for pick up.")
                            self.lblOrderStatus.text = "Your order is now ready for pickup."
                        
                        } else {
                            self.timerMinute -= 1
                            self.timerSecond = 59
                            self.lblOrderStatus.text = "Preparing your order...\nIt will be ready in \(self.timerMinute)m \(self.timerSecond)s"
                        }
                    } else {
                        self.timerSecond -= 1
                        self.lblOrderStatus.text = "Preparing your order...\nIt will be ready in \(self.timerMinute)m \(self.timerSecond)s"
                    }
                }
            }
        }
//        else {
//            // NOTE: FOR DEBUGGING ONLY!!!
//            lblOrderStatus.text = "Distance to store is \(distance)m"
//        }
        
        print("Distance from store \(String(format: "%.2f", distance))m")
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is HistoryViewController {
            let view = segue.destination as! HistoryViewController
            view.loggedUser = loggedUser
        }
    }
}
