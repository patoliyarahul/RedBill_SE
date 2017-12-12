//
//  ItemDetailVC.swift
//  RedBill
//
//  Created by Rahul on 10/29/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import Alamofire
import ImageSlideshow

class ItemDetailVC: UIViewController {
    
    @IBOutlet weak var slideShow: ImageSlideshow!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var lblStatus: UILabel!
    
    var imagePath: String = ""
    var alamofireSource = [AlamofireSource]()
    let localSource = [ImageSource(imageString: "no_image")!]
    var dict = Dictionary<String, Any> ()
    var isDismissedByPresented: Bool = false
    
}

//MARK: - LifeCycle
extension ItemDetailVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.layer.zPosition = 0 // RK
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isTranslucent = true
        setText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isDismissedByPresented {
            isDismissedByPresented = !isDismissedByPresented
        }else {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifire.editItemSegue {
            let dv = segue.destination as! ManageListingVC
            dv.dict = sender as! Dictionary<String, Any>
            dv.isEdit = true
            dv.imagePath = self.imagePath
        }
    }
}

//MARK: - UIButton Action Methods
extension ItemDetailVC {
    @IBAction func btnEditClicked(_ sender: Any) {
        self.performSegue(withIdentifier: SegueIdentifire.editItemSegue, sender: dict)
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = true

        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - Initialization Method
extension ItemDetailVC {
    
    func setText() {
        if let arrImages = dict[API_param.Product.images]! as? [String] {
            if arrImages.count >= 1 {
                for item in arrImages {
                    let url: String = "\(self.imagePath)\(item)"
                    alamofireSource.append(AlamofireSource(urlString: url)!)
                }
            }
        }
        
        lblTitle.text = (dict[API_param.Product.title] as! String)
        lblPrice.text =  "$ \(String(describing: dict[API_param.Product.price] as! String))"
        txtDescription.text =  dict[API_param.Product.description] as! String
        
        let status = dict[API_param.Product.status] as! String
        switch status {
        case "A":
            lblStatus.text = "ACTIVE"
            lblStatus.textColor = uiColorFromHex(rgbValue: 0x00B4B2)
        case "S":
            lblStatus.text = "SOLD"
            lblStatus.textColor = uiColorFromHex(rgbValue: 0xEA1917)
        case "D":
            lblStatus.text = "CANCELED"
            lblStatus.textColor = uiColorFromHex(rgbValue: 0x9B9B9B)
        default:
            lblStatus.text = "ACTIVE"
        }
        
        setSlidView()
    }
    func setSlidView() {
        self.slideShow.backgroundColor = UIColor.black
        self.slideShow.slideshowInterval = 10.0
        self.slideShow.pageControlPosition = PageControlPosition.insideScrollView
        self.slideShow.pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        self.slideShow.pageControl.pageIndicatorTintColor = UIColor.black
        self.slideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        self.slideShow.activityIndicator = DefaultActivityIndicator()
        self.slideShow.currentPageChanged = { page in
            //            print("current page:", page)
        }
        
        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        self.slideShow.setImageInputs(alamofireSource.count > 0 ? alamofireSource : localSource)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        self.slideShow.addGestureRecognizer(recognizer)
    }
    @objc func didTap() {
        isDismissedByPresented = true
        let fullScreenController = self.slideShow.presentFullScreenController(from: self)
        // set the activity indicator for fullasreen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
}

