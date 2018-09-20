//
//  Extensions.swift
//  ARtist
//
//  Created by Anthony Krivonos on 4/30/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import Foundation
import UIKit

import UIScreenExtension

// MARK: - Date
extension Date {
    
    func getPrettyDate() -> String{
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let myString = formatter.string(from: Date()) // string purpose I add here
        // convert your string to date
        let formattedDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "MMM dd, yyyy"
        // again convert your date to string
        let formatted = formatter.string(from: formattedDate!)
        
        return formatted
    }
    
}

// MARK: - UIImage
extension UIImage {
    var isPortrait:  Bool    { return size.height > size.width }
    var isLandscape: Bool    { return size.width > size.height }
    var breadth:     CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
    var squared: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizeWith(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeWith(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    /// Resizes an image to fit a rectangle
    func resizeTo(rect:CGRect) -> UIImage {
        let widthRatio  = rect.width  / size.width
        let heightRatio = rect.height / size.height
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        // This is the rect that we've calculated out and this is what is actually used below
        let newRect = CGRect(x: rect.minX, y: rect.minY, width: newSize.width, height: newSize.height)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: newRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
}

// MARK: - UIView
extension UIView {
    
    // MARK: - IBInspectables
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            let color = UIColor(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    /// Round specific corners of a view
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        layer.masksToBounds = true
        clipsToBounds = true
    }
    
    /// Remove all rounded corners of a view
    func unroundCorners() {
        let path = UIBezierPath(rect: self.bounds)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    /// Add UIBlurEffect to UIView
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
        self.sendSubview(toBack: blurEffectView)
    }
    /// Remove UIBlurEffect from UIView
    func removeBlurEffect() {
        let blurredEffectViews = self.subviews.filter{$0 is UIVisualEffectView}
        blurredEffectViews.forEach{ blurView in
            blurView.removeFromSuperview()
        }
    }
    
    /// Loads a view from nib.
    @discardableResult
    func fromNib<T : UIView>() -> T? {
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {
            return nil
        }
        self.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layoutAttachAll(to: self)
        return contentView
    }
    
    func layoutAttachAll(to childView:UIView) {
        var constraints = [NSLayoutConstraint]()
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(NSLayoutConstraint(item: childView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(item: childView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(item: childView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(item: childView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        
        childView.addConstraints(constraints)
    }
    
    
    /// Pins edges of a subiew to a superview
    func pinEdgesToSuperview(byConstant constant:CGFloat = 0) {
        if self.superview == nil {
            // Return if view has no superviews
            return
        }
        
        // Add constraints
        self.superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.superview, attribute: .top, multiplier: 1, constant: constant))
        self.superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.superview, attribute: .bottom, multiplier: 1, constant: constant))
        self.superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.superview, attribute: .leading, multiplier: 1, constant: constant))
        self.superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.superview, attribute: .trailing, multiplier: 1, constant: constant))
        
        self.superview?.updateConstraints()
        self.superview?.layoutIfNeeded()
    }
    
    //
    // Bucket Animations
    //
    
    /// Bucket-specific Animation with damping
    static func bkDampAnimation(withDuration duration:Double = 0.5, andDelay delay:Double = 0, animations:@escaping ()->Void, completion:((_ completed:Bool)->Void)? = nil) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: CGFloat(duration*2), initialSpringVelocity: CGFloat(duration*2.5), options: .curveEaseInOut, animations: animations, completion: completion)
    }
    
    /// Bucket-specific Linear Animation
    static func bkLinearAnimation(withDuration duration:Double = 0.5, andDelay delay:Double = 0, animations:@escaping ()->Void, completion:((_ completed:Bool)->Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: [.curveLinear], animations: animations, completion: completion)
    }
    
    /// Bucket-specific Curve Ease In Animation
    static func bkEaseInAnimation(withDuration duration:Double = 0.5, andDelay delay:Double = 0, animations:@escaping ()->Void, completion:((_ completed:Bool)->Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseIn], animations: animations, completion: completion)
    }
    
    /// Bucket-specific Curve Ease Out Animation
    static func bkEaseOutAnimation(withDuration duration:Double = 0.5, andDelay delay:Double = 0, animations:@escaping ()->Void, completion:((_ completed:Bool)->Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseOut], animations: animations, completion: completion)
    }
    
    /// Bucket-specific Autoreverse Animation
    static func bkAutoreverseAnimation(withDuration duration:Double = 0.5, andDelay delay:Double = 0, animations:@escaping ()->Void, completion:((_ completed:Bool)->Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: [.autoreverse, .repeat, .curveEaseOut], animations: animations, completion: completion)
    }
}

// MARK: - Array where Element:Hashable
extension Array where Element:Hashable {
    
    /// Creates a set, or a unique list of elements.
    var set:Array<Element> {
        return Array(Set<Element>(self))
    }
    
}

// MARK: - CGFloat
extension CGFloat {
    
    /// Returns the float in terms of real world meters
    var toMeters:CGFloat {
        if let pointsPerCentimeter = UIScreen.pointsPerCentimeter {
            return (self/pointsPerCentimeter)/100.0
        }
        return 0.0
    }
    
}

// MARK - Data
extension Data {
    
    var sizeInMB:Float {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB]
        bcf.countStyle = .file
        return Float(bcf.string(fromByteCount: Int64(self.count))) ?? 0.0
    }
    
}

// MARK: - Date
extension Date {
    
    /// Return a string time differential from the given date
    func timeAgo(from date:Date = Date()) -> String {
        
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: date).second ?? 0
            return "\(diff)s ago"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: date).minute ?? 0
            return "\(diff)m ago"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: date).hour ?? 0
            return "\(diff)h ago"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: date).day ?? 0
            return "\(diff)d ago"
        }
        
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: date).weekOfYear ?? 0
        return "\(diff)w ago"
    }
    
}

// MARK: - UIColor
extension UIColor {
    
    var coreImageColor:CIColor {
        return CIColor(color:self)
    }
    
    var rgb:(red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
    
    /// Used for calculating darkness-related modifications such as overlay text color.
    var isLightColor:Bool {
        return (1 - ( 0.299 * rgb.red + 0.587 * rgb.green + 0.114 * rgb.blue)/255 >= 0.5)
    }
    
    /// Gets highlighted color from the current color
    func getHighlighted() -> UIColor {
        return isLightColor ? (lighter() ?? self) : (darker() ?? self)
    }
    
    /// Get lighter color from current UIColor - used for highlighting.
    private func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    /// Get darker color from current UIColor - used for highlighting.
    private func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    /// Helper method for lighter and darker methods.
    private func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        } else {
            return nil
        }
    }
    
}
