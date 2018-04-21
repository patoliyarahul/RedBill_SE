//
//  ChatListVC.swift
//  RedBill
//
//  Created by Dharmesh Vaghani on 08/01/18.
//  Copyright © 2018 Rahul. All rights reserved.
//

import UIKit
import Firebase

//MARK : - Variables and IBOutlets

class ChatListVC: UIViewController {
    @IBOutlet weak var noMessageView: UIView!
    @IBOutlet weak var myTableView: UITableView!
    
    //MARK: - Variables for firebase
    lazy var recentRef: DatabaseReference = Database.database().reference().child(FRecentParams.FRECENT_PATH)
    var recentRefHandleNew: DatabaseHandle?
    var recentRefHandleChange: DatabaseHandle?
    
    var recents: [Recent] = []
}

//MARK: - LifeCycle Methods
extension ChatListVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noMessageView.alpha = 0
        self.view.bringSubview(toFront: noMessageView)
        
        navigationController?.navigationBar.ReSetCustomNavigationBar()
        
        configureTableView(myTableView)
        observeChannels()
        sortRecentArray()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default

        if let selected = myTableView.indexPathForSelectedRow {
            myTableView.deselectRow(at: selected, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK :- Navigation Method
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifire.showChatSegue {
            let dv = segue.destination as! ChatViewController
            dv.recent = sender as! Recent
        }
    }
}

// MARK: - Helper Methods

extension ChatListVC {
    
}

//MARK: - Firebase Helper Methods

extension ChatListVC {
    
    func observeChannels() {
        
        // Use the observe method to listen for new
        // channels being written to the Firebase DB
        
        let userId = Auth.auth().currentUser?.uid
        
        recentRefHandleNew = recentRef.queryOrdered(byChild: FRecentParams.FRECENT_USERID).queryStarting(atValue: userId).queryEnding(atValue: userId).observe(.childAdded, with: { (snapshot) -> Void in // 1
            let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
            if let name = channelData[FRecentParams.FRECENT_USERID] as! String!, name.count > 0 { // 3
                self.recents.append(Recent(dict: channelData))
                self.sortRecentArray()
                reloadTableViewWithAnimation(myTableView: self.myTableView)
            } else {
                print("Error! Could not decode channel data")
            }
        })
        
        recentRefHandleChange = recentRef.queryOrdered(byChild: FRecentParams.FRECENT_USERID).queryStarting(atValue: userId).queryEnding(atValue: userId).observe(.childChanged, with: { (snapshot) -> Void in // 1
            let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
            if let name = channelData[FRecentParams.FRECENT_USERID] as! String!, name.count > 0 { // 3
                
                if let index = self.recents.index(where: { $0.userId == "\(channelData[FRecentParams.FRECENT_USERID]!)" }) {
                    self.recents[index] = Recent(dict: channelData)
                }
                
                self.sortRecentArray()
                reloadTableViewWithAnimation(myTableView: self.myTableView)
                
            } else {
                print("Error! Could not decode channel data")
            }
        })
    }
    
    func sortRecentArray() {
        if self.recents.count == 0 {
            noMessageView.alpha = 1
        } else {
            noMessageView.alpha = 0
            recents.sort {
                
                let date1 = Date(timeIntervalSince1970: Double("\($0.lastMessageDate)")!)
                let date2 = Date(timeIntervalSince1970: Double("\($1.lastMessageDate)")!)
                
                return date1 > date2
            }
        }
    }
}

//MARK: - UITableView Datasource and Delegate Methods

extension ChatListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let recent = recents[indexPath.row]
        
        cell.textLabel?.text = recent.description
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recent = recents[(indexPath as NSIndexPath).row]
        self.performSegue(withIdentifier: SegueIdentifire.showChatSegue, sender: recent)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let chatDict = self.recents[indexPath.row]
            
            if let index = self.recents.index(where: { $0.userId == "\(chatDict.userId)" }) {
                recents.remove(at: index)
                myTableView.deleteRows(at: [indexPath], with: .automatic)
                Database.database().reference().child(FRecentParams.FRECENT_PATH).child(chatDict.objectId).removeValue()
                
                sortRecentArray()
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62.0
    }
}

