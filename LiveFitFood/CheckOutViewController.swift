//
//  CheckOutViewController.swift
//  LiveFitFood
//
//  Created by Louise Chan on 2020-06-03.
//  Copyright © 2020 Louise Chan. All rights reserved.
//

import UIKit
import CoreData

class CheckOutViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    

    var loggedUser: User?
    var mealkit: Mealkit?
    var order: Order!
    var tip = 0.0
    var discount = 0.0
    var total = 0.0
    var tax: Double!
    
    var coupons: [Coupon] = []
    var appliedCoupon: Coupon? = nil
    
    let dbContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var lblMealkitName: UILabel!
    
    @IBOutlet weak var lblCouponHeader: UILabel!
    @IBOutlet weak var lblMealkitPrice: UILabel!
    
    @IBOutlet weak var lblSKUCode: UILabel!
    
    @IBOutlet weak var lblSubtotalPrice: UILabel!
    
    @IBOutlet weak var lblDiscountPrice: UILabel!
    
    @IBOutlet weak var txtTipAmount: UITextField!
    
    @IBOutlet weak var lblTaxAmount: UILabel!
    @IBOutlet weak var stpTipSelect: UIStepper!
    
    @IBOutlet weak var pckCoupon: UIPickerView!
    @IBOutlet weak var txtTipPercentage: UITextField!
    
    @IBOutlet weak var lblTotalPrice: UILabel!
    
    @IBOutlet weak var btnApplyCoupon: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Checkout screen")
        print("logged in user: \(loggedUser!.email!)")
        print("mealkit selected: \(mealkit!.name!)")
        
        txtTipAmount.delegate = self
        guard let mk = mealkit else {
            return
        }
        
        tax = mk.price * 0.13
        stpTipPercentValueChanged(self)
        
        lblMealkitName.text = "\(mk.name!)"
        lblMealkitPrice.text = "$\(String(format: "%.2f", mk.price))"
        lblSKUCode.text = "SKU Code: \(mk.sku!)"
        lblSubtotalPrice.text = "$\(String(format: "%.2f", mk.price))"
        lblDiscountPrice.text = "-$\(String(format: "%.2f", discount))"
        
        total = mk.price + tax - discount + tip
        lblTaxAmount.text = "$\(String(format: "%.2f", tax))"
        lblTotalPrice.text = "$\(String(format: "%.2f", total))"
        
        fetchUnusedCoupons()
        
        pckCoupon.delegate = self
        pckCoupon.dataSource = self
        // Set picker view to first data available
        pckCoupon.selectRow(0, inComponent: 0, animated: true)
        
        lblCouponHeader.textColor = UIColor.black
        
        if coupons.count == 0 {
            lblCouponHeader.text = ""
            btnApplyCoupon.isEnabled = false
            btnApplyCoupon.isHidden = true
        } else {
            lblCouponHeader.text = "Select coupon to apply:"
            btnApplyCoupon.isEnabled = true
            btnApplyCoupon.isHidden = false
        }
        
        
        
        
    }
    
    func fetchUnusedCoupons() {
        let request : NSFetchRequest<Coupon> = Coupon.fetchRequest()
        
        // Query for coupons that are unused
        let query = NSPredicate(format: "isUsed == false AND owner == %@", loggedUser!)
        request.predicate = query

        do {
            // store sorted pokemons in the Pokemon array
            coupons = try dbContext.fetch(request)
        } catch {
            print("Error reading from database")
        }

    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textFieldDidEndEditing(textField)
        
        total = mealkit!.price + tax - discount + tip
        lblTotalPrice.text = "$\(String(format: "%.2f", total))"
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        tip = Double(txtTipAmount.text ?? "0.0") ?? 0.0
        txtTipAmount.text = "\(String(format:"%.2f", tip))"
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coupons.count
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return "\(coupons[row].code) \(Int(coupons[row].discount))%"
//    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let v = view {
            label = v as! UILabel
        }
        label.font = UIFont (name: "Helvetica Neue", size: 14)
        label.text = "\(String(format: "%010u", coupons[row].code))\t(\(Int(coupons[row].discount))%)"
        label.textAlignment = .center
        return label
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func btnProceedPressed(_ sender: Any) {
        print("Proceed button pressed")
        order = Order(context: dbContext)
        order.buyer = loggedUser
        order.datetime = Date() as NSDate?
        order.discount = appliedCoupon
        order.item = mealkit
        order.number = Int64(order.datetime!.hashValue)
        order.tip = tip
        order.total = total
        
        if appliedCoupon != nil {
            appliedCoupon?.appliedTo = order
            appliedCoupon?.isUsed = true
        }
        
        do {
            try dbContext.save()
        } catch {
            print("Error saving order!")
            print(error.localizedDescription)
        }
        
        print("Order: \(order!)")
        
        performSegue(withIdentifier: "orderSummarySegue", sender: self)
    }
    
    @IBAction func btnApplyCouponPressed(_ sender: Any) {
        print("Apply coupon pressed")
        appliedCoupon = coupons[pckCoupon.selectedRow(inComponent: 0)]
        discount = (appliedCoupon!.discount/100) * mealkit!.price
        total = mealkit!.price + tax - discount + tip
        lblTotalPrice.text = "$\(String(format: "%.2f", total))"
        lblDiscountPrice.text = "-$\(String(format: "%.2f", discount))"
        btnApplyCoupon.isEnabled = false
        btnApplyCoupon.isHidden = true
        lblCouponHeader.text = "Discount was applied to order."
        lblCouponHeader.textColor = UIColor.red
    }
    
    @IBAction func stpTipPercentValueChanged(_ sender: Any) {
        txtTipPercentage.text = "\(Int(stpTipSelect.value))"
        tip = mealkit!.price * (stpTipSelect.value/100)
        txtTipAmount.text = "\(String(format:"%.2f", tip))"
        total = mealkit!.price + tax - discount + tip
        lblTotalPrice.text = "$\(String(format: "%.2f", total))"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let view = segue.destination as! OrderSummaryViewController
        view.loggedUser = loggedUser
        view.order = order
    }
}
