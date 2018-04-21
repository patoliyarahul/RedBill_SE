//
//  DBTextField.swift
//  SPG Stylist
//
//  Created by Dharmesh Vaghani on 30/04/17.
//  Copyright © 2017 Dharmesh Vaghani. All rights reserved.
//

import UIKit

class DBTextField: TextFieldEffects {

    /**
     The color of the border when it has no content.
     
     This property applies a color to the lower edge of the control. The default value for this property is a clear color. This value is also applied to the placeholder color.
     */
    @IBInspectable dynamic open var inactiveColor: UIColor? {
        didSet {
            updateBorder()
        }
    }
    
    var txtConfirmpass = UITextField()
    var confirmMessage = ""

    var isMendatory         = true
    var mendatoryMessage    = "Shuld not be empty"
    
    var regEx               = ""
    var regExMessage        = ""
    
    /**
     The color of the border when it has content.
     
     This property applies a color to the lower edge of the control. The default value for this property is a clear color.
     */
    @IBInspectable dynamic open var activeColor: UIColor? {
        didSet {
            updateBorder()
        }
    }
    
    @IBInspectable dynamic open var placeholderInactiveColor: UIColor? {
        didSet {
            updatePlaceholder()
        }
    }
    
    @IBInspectable dynamic open var borderInactiveColor: UIColor? {
        didSet {
            updateBorder()
        }
    }
    
    @IBInspectable dynamic open var errorColor : UIColor = .red {
        didSet {
            _ = validate()
        }
    }
    
    @IBInspectable dynamic open var placeHolderFontName : String = "Helvetica" {
        didSet {
            placeholderFontFromFont()
        }
    }
    
    @IBInspectable dynamic open var placeHolderFontSize : CGFloat = 10.0 {
        didSet {
            placeholderFontFromFont()
        }
    }
    
    /**
     The scale of the placeholder font.
     
     This property determines the size of the placeholder label relative to the font size of the text field.
     */
    @IBInspectable dynamic open var placeholderFontScale: CGFloat = 0.7 {
        didSet {
            updatePlaceholder()
        }
    }
    
    override open var placeholder: String? {
        didSet {
            updatePlaceholder()
        }
    }
    
    override open var bounds: CGRect {
        didSet {
            updateBorder()
            updatePlaceholder()
        }
    }
    
    private let borderThickness: (active: CGFloat, inactive: CGFloat) = (1, 1)
    private let placeholderInsets = CGPoint(x: 6, y: 6)
    private let textFieldInsets = CGPoint(x: 0, y: 40)
    private let borderLayer = CALayer()
    
    // MARK: - TextFieldEffects
    
    override open func drawViewsForRect(_ rect: CGRect) {
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: rect.size.width, height: rect.size.height))
        
        placeholderLabel.frame = frame.insetBy(dx: placeholderInsets.x, dy: placeholderInsets.y)
        placeholderFontFromFont()
        
        updateBorder()
        updatePlaceholder()
        
        layer.addSublayer(borderLayer)
        addSubview(placeholderLabel)
        
        tintColor = textColor
    }
    
    override open func animateViewsForTextEntry() {
        updateBorder()
        if let activeColor = activeColor {
            performPlaceholderAnimationWithColor(activeColor)
        }
    }
    
    override open func animateViewsForTextDisplay() {
        updateBorder()
        if let inactiveColor = inactiveColor {
            performPlaceholderAnimationWithColor(inactiveColor)
        }
    }
    
    // MARK: - Private
    
    private func updateBorder() {
        borderLayer.frame = rectForBorder(frame)
        borderLayer.backgroundColor = isFirstResponder ? activeColor?.cgColor : borderInactiveColor?.cgColor
        placeholderLabel.textColor = isFirstResponder ? activeColor : placeholderInactiveColor
    }
    
    private func updatePlaceholder() {
        placeholderLabel.text = placeholder
        placeholderLabel.textColor = placeholderInactiveColor
        placeholderLabel.sizeToFit()
        layoutPlaceholderInTextRect()
        
        if isFirstResponder {
            animateViewsForTextEntry()
        }
        
        placeholderLabel.frame.origin = CGPoint.zero
    }
    
    private func placeholderFontFromFont() {
        placeholderLabel.font = UIFont(name: placeHolderFontName, size: placeHolderFontSize)
    }
    
    private func rectForBorder(_ bounds: CGRect) -> CGRect {
        var newRect:CGRect
        
        if isFirstResponder {
            newRect = CGRect(x: 0, y: bounds.size.height - borderThickness.active, width: bounds.size.width, height: borderThickness.active)
        } else {
            newRect = CGRect(x: 0, y: bounds.size.height - borderThickness.inactive, width: bounds.size.width, height: borderThickness.inactive)
        }
        
        return newRect
    }
    
    private func layoutPlaceholderInTextRect() {
        let textRect = self.textRect(forBounds: bounds)
        var originX = textRect.origin.x
        switch textAlignment {
        case .center:
            originX += textRect.size.width/2 - placeholderLabel.bounds.width/2
        case .right:
            originX += textRect.size.width - placeholderLabel.bounds.width
        default:
            break
        }
        placeholderLabel.frame = CGRect(x: originX, y: bounds.height - placeholderLabel.frame.height,
                                        width: bounds.size.width, height: placeholderLabel.frame.size.height)
    }
    
    private func performPlaceholderAnimationWithColor(_ color: UIColor) {
        
        let yOffset: CGFloat = 0
        
        UIView.animate(withDuration: 0.15, animations: {
            self.placeholderLabel.transform = CGAffineTransform(translationX: 0, y: -yOffset)
            self.placeholderLabel.text = self.placeholder
            self.placeholderLabel.alpha = 0
        }) { _ in
            self.placeholderLabel.transform = CGAffineTransform.identity
            self.placeholderLabel.transform = CGAffineTransform(translationX: 0, y: yOffset)
            
            UIView.animate(withDuration: 0.15, animations: {
                self.placeholderLabel.transform = CGAffineTransform.identity
                self.placeholderLabel.alpha = 1
            }) { _ in
                self.animationCompletionHandler?(self.isFirstResponder ? .textEntry : .textDisplay)
            }
        }
    }
    
    // MARK: - Overrides
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let newBounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height - font!.lineHeight + textFieldInsets.y)
        return newBounds.insetBy(dx: textFieldInsets.x, dy: 0)
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let newBounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height - font!.lineHeight + textFieldInsets.y)
        
        return newBounds.insetBy(dx: textFieldInsets.x, dy: 0)
    }
    
    func validate() -> Bool {
        if isMendatory && (self.text?.isEmpty)! {
            placeholderLabel.text =   mendatoryMessage
            placeholderLabel.textColor = errorColor
            return false
        }
        
        if !checkForRegularExpression() {
            placeholderLabel.text =  regExMessage
            placeholderLabel.textColor = errorColor
            return false
        }
        
        if !checkPassConfirmPass() {
            placeholderLabel.text = confirmMessage
            placeholderLabel.textColor = errorColor
            return false
        }
        return true
    }
    
    func checkPassConfirmPass() -> Bool {
        if !confirmMessage.isEmpty && !(self.text?.isEmpty)! {
            if self.text != txtConfirmpass.text {
                return false
            }
        }
        return true
    }
    
    func checkForRegularExpression() -> Bool
    {
        if !regEx.isEmpty && !(self.text?.isEmpty)!
        {
            let test = NSPredicate(format:"SELF MATCHES %@", regEx)
            return test.evaluate(with: self.text)
        }
        
        return true
    }

    func addRegEx(regEx : String, withMessage message : String) {
        self.regEx = regEx
        self.regExMessage = message
    }
    
    func addConfirmValidation(to : UITextField, withMessage message: String) {
        txtConfirmpass = to
        confirmMessage = message
    }

    func showCustomError(message: String) {
        self.placeholderLabel.text =  message
        self.placeholderLabel.textColor = self.errorColor
    }

}
