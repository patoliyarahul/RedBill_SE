//
//  ManageOfferVC.swift
//  RedBill
//
//  Created by Rahul on 11/9/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

/*
 //MARK: - LifeCycle
 
 //MARK: - Initialization Method
 
 //MARK: - UIButton Action Methods
 
 //MARK: - TextfieldDelegate Methods
 
 //MARK: - WebService Methods
 
 
 */


import UIKit

class ManageOfferVC: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    var arrData = [Dictionary<String, Any>]()
   
}

//MARK: - LifeCycle
extension ManageOfferVC {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - Initialization Method
extension ManageOfferVC {
    
}

//MARK: - UITableViewDelegate And Datasource Methods
extension ManageOfferVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
//        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyAccountCell
        
        cell.tintColor = uiColorFromHex(rgbValue: 0x4A4A4A)
//        cell.lblTittle.text = arrData[indexPath.row]
//        cell.lblDscription.text = arrData[indexPath.row]
        cell.lblTittle.text = "Title ---> \(indexPath.row + 1)"
        
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "detail"))

        
        if indexPath.row % 2 == 0 {
            cell.imgView.image = #imageLiteral(resourceName: "up_arrow")
            cell.lblDscription.textColor = uiColorFromHex(rgbValue: 0x00B4B2)
            cell.lblDscription.text = "OFFER SENT"
        }else{
            cell.imgView.image = #imageLiteral(resourceName: "down_arrow")
            cell.lblDscription.textColor = uiColorFromHex(rgbValue: 0xF57223)
            cell.lblDscription.text = "OFFER RECEIVED"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("This row is clicked --> \(indexPath.row+1)")
    }
}
