//
//  DefaultNavigationController.swift
//  Get Nue
//
//  Created by Rahul Patoliya on 24/03/17.
//  Copyright © 2017 Rahul Patoliya. All rights reserved.
//

import UIKit

class DefaultNavigationController: UINavigationController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
    
        self.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "Back_arrow")
        self.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "Back_arrow")
    
        self.navigationBar.tintColor = UIColor.white
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension UINavigationBar
{
    func SetCustomNavigationBar()
    {
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
        self.backIndicatorImage = #imageLiteral(resourceName: "Back_arrow")
        self.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "Back_arrow")
        self.tintColor = UIColor.white
    }
    
    func ReSetCustomNavigationBar()
    {
        self.shadowImage = UIImage()
        self.barStyle = .default
        self.isTranslucent = false
        self.backIndicatorImage = #imageLiteral(resourceName: "Back_arrow")
        self.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "Back_arrow")
        self.tintColor = UIColor.black
        self.barTintColor = Color.navBarColor
    }
}
