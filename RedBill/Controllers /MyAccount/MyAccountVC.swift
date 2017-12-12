//
//  MyAccountVC.swift
//  RedBill
//
//  Created by Rahul on 11/9/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit

class MyAccountVC: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    
    var arrData = ["My Offers","Transaction History","Payment Methods","Settings"]
    var arrImages = ["offer","history","credit-card","Setting"]
    
}

//MARK: - LifeCycle
extension MyAccountVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.tableFooterView = UIView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed

    }
}

//MARK: - Initialization Method
extension MyAccountVC {
    
}

//MARK: - UIButton Action Methods
extension MyAccountVC {
    @IBAction func btnCloseClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnLogoutClicked(_ sender: Any) {
    }
}

//MARK: - UITableViewDelegate And Datasource Methods
extension MyAccountVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyAccountCell
        
        cell.lblTittle.text = arrData[indexPath.row]
        cell.imgView.image = UIImage(named: arrImages[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            self.performSegue(withIdentifier: SegueIdentifire.manageOfferSegue, sender: nil)
            break
        case 1:
            self.performSegue(withIdentifier: SegueIdentifire.historySegue, sender: nil)
            break
        case 2:
            self.performSegue(withIdentifier: SegueIdentifire.managePaymentSegue, sender: nil)
            break
        case 3:
            self.performSegue(withIdentifier: SegueIdentifire.settingSegue, sender: nil)
            break
        default:
            break
        }
        print("This row is clicked --> \(indexPath.row+1)")
    }
}
