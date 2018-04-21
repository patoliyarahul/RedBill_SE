//
//  MSAlertController.swift
//  
//
//  Created by JD on 19/10/2016.
//  Copyright © 2017 JD. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertAction {
    
    /// Action types most commonly used
    public enum actionType{
        
        ///Ok Option
        case ok
        
        /// Default Cancel Option
        case cancel
        
        /// Destructive action with custom title
        case destructive(String)
        
        /// Custom action with title and style
        case custom(String,UIAlertActionStyle)
        
        /**
         Creates the action instance for UIAlertController
            - parameter handler: Call Back function
            - returns UIAlertAction Instance
         */
        public func action(handler:((String) -> Void)? = nil) -> UIAlertAction {
            
            //Default value
            var actionStyle = UIAlertActionStyle.default
            var title = ""
            
            // Action configuration based on the action type
            switch self {
                
            case .cancel:
                actionStyle = .cancel
                title = staus.Cancel
                
            case .destructive(let optionTitle):
                title = optionTitle
                actionStyle = .destructive
                
            case .custom(let optionTitle, let style):
                title = optionTitle
                actionStyle = style
                
            default:
                title = "Ok"
            }
           
            //Creating UIAlertAction instance
            let action = UIAlertAction(title:title,style:actionStyle, handler: {(nativeAction) in
                if (handler != nil){
                    handler!(title)
                }
            })
            
            return action
        }
    }
}

extension UIAlertController {
    
    /**
     Creates the alert view controller using the actions specified
     
     - parameter title:  Title of the alert.
     - parameter message: Alert message body.
     - parameter actions: Variable numbre of actions as an Array of actionType values.
     - parameter style: UIAlertControllerStyle enum value
     - parameter handler: Handler block/closure for the clicked option.
     
     -     let alert = UIAlertController.init(title:"Confirm",message:"Do you want to quit sign up and login with other account ?",actions:.custom("Yes,.default),.custom(staus.Cancel,.destructive)){ (buttonTitle) in
            if buttonTitle == "Yes"{
                print("Yes Clicked")
            }
     }
     
     self.present(alert, animated: true, completion: nil)

     */
    convenience init(title: String, message: String ,actions:UIAlertAction.actionType?...,style: UIAlertControllerStyle = .alert,handler:((String) -> Swift.Void)? = nil) {
        
        //initialize the contoller (self) instance
        self.init(title: title, message: message, preferredStyle:style)
       
        if actions.isEmpty {
            addAction(UIAlertAction.actionType.ok.action(handler: handler))
        }
        else{
            //Fetching actions specidied by the user and adding actions accordingly
            for actionType in actions {
                addAction((actionType?.action(handler: handler))!)
            }
        }
        
    }
}


class mydemo {
    let alert = UIAlertController()
}
