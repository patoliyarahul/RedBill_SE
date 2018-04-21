//
//  TermsVC.swift
//  RedBill
//
//  Created by Rahul on 9/20/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import Alamofire

class TermsVC: UIViewController {
    
    @IBOutlet weak var txtView: UITextView!
}

//MARK: LifeCycle
extension TermsVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        callService_get_content()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//MARK: - WebService Methods
    func callService_get_content() {
        
        let param: Parameters = [API_param.Content.code:"TC"]
        
        Utils.Show()
        
        Alamofire.request(URL(string: fromURL(uri: ApiName.get_content))!, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                //                print(response.result.value as Any)   // result of response serialization
                Utils.HideHud()
                if let json = response.result.value as? Dictionary<String, Any> {
                    if json[API_param.status] as? Int == 1 {
                        let data: Dictionary<String, Any> = (json[API_param.data] as? Dictionary<String, Any>)!
                        
                        let htmlString:String = data[API_param.Content.content] as! String
                        var str = NSAttributedString()
                        do {
                            str = try NSAttributedString(data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType], documentAttributes: nil)
                        } catch {
                            print(error)
                        }
                        self.txtView.attributedText = str
                        self.txtView.textColor = UIColor.black
                        
                    }else {
                        print("Message : \(String(describing: json[API_param.message]!))")
                    }
                }
        }
    }
}

