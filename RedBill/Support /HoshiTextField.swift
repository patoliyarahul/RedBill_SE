//
//  HoshiTextField.swift
//  TextFieldEffects
//
//  Created by Dharmesh Vaghani on 30/04/17.
//  Copyright © 2017 Dharmesh Vaghani. All rights reserved.
//

import UIKit

/**
 An HoshiTextField is a subclass of the TextFieldEffects object, is a control that displays an UITextField with a customizable visual effect around the lower edge of the control.
 */
@IBDesignable open class HoshiTextField: TextFieldEffects {
    
    var txtConfirmpass = UITextField()
    var confirmMessage = ""
    
    /**
     The color of the border when it has no content.
     
     This property applies a color to the lower edge of the control. The default value for this property is a clear color.
     */
    @IBInspectable dynamic open var borderInactiveColor: UIColor? {
        didSet {
            updateBorder()
        }
    }
    
    var isMendatory         = true
    var mendatoryMessage    = "Shuld not be empty"
    
    var regEx               = ""
    var regExMessage        = ""
    
    /**
     The color of the border when it has content.
     
     This property applies a color to the lower edge of the control. The default value for this property is a clear color.
     */
    @IBInspectable dynamic open var borderActiveColor: UIColor? {
        didSet {
            updateBorder()
        }
    }
    
    @IBInspectable dynamic open var showPlaceWhileEditing : Bool = true  {
        didSet {
            updatePlaceholder()
        }
    }
    
    @IBInspectable dynamic open var errorColor : UIColor = .red {
        didSet {
            _ = validate()
        }
    }
    
    /**
     The color of the placeholder text.
     
     This property applies a color to the complete placeholder string. The default value for this property is a black color.
     */
    @IBInspectable dynamic open var placeholderColor: UIColor = .black {
        didSet {
            updatePlaceholder()
        }
    }
    
    /**
     The scale of the placeholder font.
     
     This property determines the size of the placeholder label relative to the font size of the text field.
     */
    @IBInspectable dynamic open var placeholderFontScale: CGFloat = 1 {
        didSet {
            updatePlaceholder()
        }
    }
    
    @IBInspectable dynamic open var errorLabelFontScale : CGFloat = 0.65 {
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
    
    private let borderThickness: (active: CGFloat, inactive: CGFloat) = (active: 1, inactive: 1)
    private let errorLabelInsets = CGPoint(x: 0, y: -15)
    private let placeholderInsets = CGPoint(x: 0, y: 6)
    private let textFieldInsets = CGPoint(x: 0, y: 6)
    private let inactiveBorderLayer = CALayer()
    private let activeBorderLayer = CALayer()
    
    // MARK: - TextFieldEffects
    
    override open func drawViewsForRect(_ rect: CGRect) {
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: rect.size.width, height: rect.size.height))
        
        placeholderLabel.frame = frame.offsetBy(dx: placeholderInsets.x, dy: placeholderInsets.y)
        placeholderLabel.font = placeholderFontFromFont(font!)
        
        errorLabel.frame = frame.offsetBy(dx: placeholderInsets.x, dy: errorLabelInsets.y)
        errorLabel.font = errorLableFontFromFont(font!)
        
        self.tintColor = borderActiveColor
        
        updateBorder()
        updatePlaceholder()
        
        layer.addSublayer(inactiveBorderLayer)
        layer.addSublayer(activeBorderLayer)
        addSubview(placeholderLabel)
        addSubview(errorLabel)
    }
    
    override open func animateViewsForTextEntry() {
        updateBorder()
        if text!.isEmpty {
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .beginFromCurrentState, animations: ({
                self.placeholderLabel.frame.origin = CGPoint(x: 10, y: self.placeholderLabel.frame.origin.y)
                self.placeholderLabel.alpha = 0
            }), completion: { _ in
                self.animationCompletionHandler?(.textEntry)
            })
        }
        
        activeBorderLayer.frame = rectForBorder(borderThickness.active, isFilled: true)
    }
    
    override open func animateViewsForTextDisplay() {
        updateBorder()
        if text!.isEmpty {
            UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: ({
                self.layoutPlaceholderInTextRect()
                self.placeholderLabel.alpha = 1
            }), completion: { _ in
                self.animationCompletionHandler?(.textDisplay)
            })
            
            activeBorderLayer.frame = self.rectForBorder(self.borderThickness.active, isFilled: false)
        }
    }
    
    // MARK: - Private
    
    private func updateBorder() {
        inactiveBorderLayer.frame = rectForBorder(borderThickness.inactive, isFilled: true)
        inactiveBorderLayer.backgroundColor = borderInactiveColor?.cgColor
        
        activeBorderLayer.frame = rectForBorder(borderThickness.active, isFilled: false)
        activeBorderLayer.backgroundColor = isFirstResponder ? borderActiveColor?.cgColor : borderInactiveColor?.cgColor
        self.errorLabel.alpha = 0
    }
    
    private func updatePlaceholder() {
        placeholderLabel.text = placeholder
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.sizeToFit()
        layoutPlaceholderInTextRect()
        
        if isFirstResponder || text!.isNotEmpty {
            animateViewsForTextEntry()
        }
    }
    
    private func placeholderFontFromFont(_ font: UIFont) -> UIFont! {
        let smallerFont = UIFont(name: font.fontName, size: font.pointSize * placeholderFontScale)
        return smallerFont
    }
    
    private func errorLableFontFromFont(_ font: UIFont) -> UIFont! {
        let smallerFont = UIFont(name: font.fontName, size: font.pointSize * errorLabelFontScale)
        return smallerFont
    }
    
    private func rectForBorder(_ thickness: CGFloat, isFilled: Bool) -> CGRect {
        if isFilled {
            return CGRect(origin: CGPoint(x: 0, y: frame.height-thickness), size: CGSize(width: frame.width, height: thickness))
        } else {
            return CGRect(origin: CGPoint(x: 0, y: frame.height-thickness), size: CGSize(width: 0, height: thickness))
        }
    }
    
    private func layoutPlaceholderInTextRect() {
        let textRect = self.textRect(forBounds: bounds)
        var originX = textRect.origin.x
        switch self.textAlignment {
        case .center:
            originX += textRect.size.width/2 - placeholderLabel.bounds.width/2
        case .right:
            originX += textRect.size.width - placeholderLabel.bounds.width
        default:
            break
        }
        placeholderLabel.frame = CGRect(x: originX, y: placeholderInsets.y, width: placeholderLabel.bounds.width, height: bounds.height)
    }
    
    // MARK: - Overrides
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.offsetBy(dx: textFieldInsets.x, dy: textFieldInsets.y)
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.offsetBy(dx: textFieldInsets.x, dy: textFieldInsets.y)
    }
    
    func validate() -> Bool {
        if isMendatory && (self.text?.isEmpty)! {
            errorLabel.alpha = 1
            errorLabel.text = mendatoryMessage
            errorLabel.textColor = errorColor
            return false
        }
        
        if !checkForRegularExpression() {
            errorLabel.alpha = 1
            errorLabel.text = regExMessage
            errorLabel.textColor = errorColor
            return false
        }
        
        if !checkPassConfirmPass() {
            errorLabel.alpha = 1
            //            errorLabel.text = self.placeholder! + "   " + confirmMessage
            errorLabel.text = confirmMessage
            errorLabel.textColor = errorColor
            return false
        }
        
        return true
    }
    
    func checkForRegularExpression() -> Bool {
        if !regEx.isEmpty && !(self.text?.isEmpty)! {
            let test = NSPredicate(format:"SELF MATCHES %@", regEx)
            return test.evaluate(with: self.text)
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
    
    func addRegEx(regEx : String, withMessage message : String) {
        self.regEx = regEx
        self.regExMessage = message
    }
    
    func addConfirmValidation(to : UITextField, withMessage message: String) {
        txtConfirmpass = to
        confirmMessage = message
    }
    
    func showCustomError(message: String) {
        self.placeholderLabel.text = message
        self.placeholderLabel.textColor = self.errorColor
    }
    
}
