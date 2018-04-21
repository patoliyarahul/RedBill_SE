//
//  CardView.swift
//  CP
//
//  Created by AppstoneLab on 16/06/17.
//  Copyright © 2017 Riddhi . All rights reserved.
//

import UIKit
@IBDesignable
class CardView: UIView {
    
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.5
    
    @IBInspectable  var cornerRadius: CGFloat = 0.0
    {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable  var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable  var borderWidth: CGFloat = 0.0
        {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0.0, height: 0.0) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable  var shadowRadius: CGFloat = 0.0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    
    override func layoutSubviews()
    {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
        
    }
}

