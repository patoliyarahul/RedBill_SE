//
//  BaseTabBar.swift
//  RedBill
//
//  Created by Rahul on 10/10/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit

class BaseTabBar: UITabBarController
{
    
    let tabHeight:CGFloat = Utils.whichDevice() == DeviceType.IPhoneX.rawValue ? 100.00 : 65.00
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        UpdateSelectionIamge()
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        UpdateSelectionIamge()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
    {
        if item.tag == 1
        {
            let actionSheet = UIAlertController(title: "Add Photos", message: "", preferredStyle: .actionSheet)
            let takePhotoAction = UIAlertAction(title: "Take a Photo", style: .default, handler: { action in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera;
                    imagePicker.allowsEditing = false
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            let uploadPhotoAction = UIAlertAction(title: "Upload Photo", style: .default, handler: { action in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary;
                    imagePicker.allowsEditing = false
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            
            let cancelAction = UIAlertAction(title: staus.Cancel, style: .cancel, handler: {
            action in
                self.selectedIndex = 0
            })
            
            actionSheet.addAction(takePhotoAction)
            actionSheet.addAction(uploadPhotoAction)
            actionSheet.addAction(cancelAction)
            
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func UpdateSelectionIamge()
    {
        var tabFrame = self.tabBar.frame
        // - 40 is editable , the default value is 49 px, below lowers the tabbar and above increases the tab bar size
        tabFrame.size.height = tabHeight
        tabFrame.origin.y = self.view.frame.size.height - tabHeight
        self.tabBar.frame = tabFrame
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//MARK: - UIImagePickerControllerDelegate
extension BaseTabBar: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        var imagePass: UIImage = UIImage()
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        {
            imagePass = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            imagePass = originalImage
        }
        let nc = self.viewControllers![2] as! UINavigationController
        if nc.topViewController is ManageVC
        {
            let svc:ManageVC = nc.topViewController as! ManageVC
            svc.pic = imagePass
            svc.isFromCamera = true
        }
        self.selectedIndex = 2
        dismiss(animated: true, completion: {})
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: {
            self.selectedIndex = 0
        })
    }
}

