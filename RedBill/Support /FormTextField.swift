//
//  FormTextField.swift
//  Get Nue
//
//  Created by Rahul Patoliya on 12/04/17.
//  Copyright © 2017 Rahul Patoliya. All rights reserved.
//

import UIKit

@IBDesignable

class FormTextField: TextFieldValidator {
    
    @IBInspectable var inset: CGFloat = 0
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: inset)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
}
