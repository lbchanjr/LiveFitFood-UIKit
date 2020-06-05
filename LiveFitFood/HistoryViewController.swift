//
//  HistoryViewController.swift
//  LiveFitFood
//
//  Created by Louise Chan on 2020-06-03.
//  Copyright © 2020 Louise Chan. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let dbContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var loggedUser: User?
    var orders: [Order] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = false
        
        fetchUserOrders(user: loggedUser!)
        
        
    }
    
    func fetchUserOrders(user: User) {
        let request : NSFetchRequest<Order> = Order.fetchRequest()
        
        // Query for coupons that were generated on specified date
        let query = NSPredicate(format: "buyer == %@", loggedUser!)
        request.predicate = query
        
        do {
            orders = try dbContext.fetch(request)
        } catch {
            print("Error reading from database")
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as? HistoryTableViewCell
        if cell == nil {
            cell = HistoryTableViewCell(style: .default, reuseIdentifier: "historyCell")
        }
        
        let index = indexPath.row
        cell?.lblOrderNo.text = "\(String(format: "ORDER: %010u", orders[index].number))"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMM-dd"
        
        let formattedDate = dateFormatter.string(from: orders[index].datetime! as Date)
        cell?.lblOrderDate.text = "\(formattedDate)"
        
        cell?.lblOrderItem.text = "\(orders[index].item!.name!) Package"
        cell?.lblOrderAmount.text = "\(String(format: "$%.2f", orders[index].total))"
        
        return cell!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
