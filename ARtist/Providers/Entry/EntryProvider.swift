//
//  EntryProvider.swift
//  ARtist
//
//  Created by Anthony Krivonos on 8/2/24.
//  Copyright © 2024 Paraworks. All rights reserved.
//

import SwiftEntryKit

enum EntryButtonType {
    case normal
    case destructive
    case disabled
}

/// Specifies an entry button's text, action, and type
class EntryButton {
    
    public var text:String
    public var action:((Any?)->Void)?
    public var textColor:UIColor
    public var backgroundColor:UIColor
    
    init(text:String, action:((Any?)->Void)?, textColor:UIColor, backgroundColor:UIColor = .clear) {
        self.text = text
        self.action = action
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
}

/// Specifies a form field's style, content, and presentation
class EntryFormField {
    
    public var placeholder:String
    public var textColor:UIColor
    public var placeholderColor:UIColor
    public var isSecureText:Bool
    public var icon:UIImage?
    
    init(placeholder:String, textColor:UIColor, placeholderColor:UIColor, isSecureText:Bool, icon:UIImage? = nil) {
        self.placeholder = placeholder
        self.textColor = textColor
        self.placeholderColor = placeholderColor
        self.isSecureText = isSecureText
        self.icon = icon
    }
}

class EntryProvider {
    
    /// Alert attributes
    public var attributes:EKAttributes
    
    init() {
        var attributes = EKAttributes()
        
        // MARK: - Global alert attributes
        attributes.displayPriority = .high
        
        // MARK: - Position
        attributes.position = .bottom
        attributes.positionConstraints = .float
        
        attributes.entryBackground = .gradient(gradient: EKAttributes.BackgroundStyle.Gradient(colors: [Color.primary, Color.tertiary], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 3, y: 3)))
        
        // MARK: - Theme
        attributes.screenBackground = EKAttributes.BackgroundStyle.color(color: Color.gray.withAlphaComponent(0.4))
        attributes.shadow = .none
        attributes.roundCorners = .all(radius: 16)
        
        // MARK: - Feedback
        attributes.hapticFeedbackType = .success
        
        // MARK: - Animations
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        attributes.popBehavior = .animated(animation: .translation)
        
        // MARK: - Set dismissal on screen tap
        attributes.screenInteraction = .dismiss
        
        self.attributes = attributes
    }
    
    /// Display plain toast/popup message. This should only be used for statements, not prompts.
    func showToast(title:String, description:String, titleColor:UIColor = Color.offWhite, descriptionColor:UIColor = Color.gray, position:EKAttributes.Position, duration:Double = .infinity, image:UIImage?) {
        
        // Set Duration
        self.attributes.displayDuration = duration
        
        // Set background color and position
        self.attributes.position = position
        
        //
        // MARK: - Toast-specific settings below
        //
        
        // Create content containers for text strings
        let titleContent = EKProperty.LabelContent(text: title, style: .init(font: UIFont.systemFont(ofSize: 24, weight: .heavy), color: titleColor, alignment: image != nil ? .left : .center, numberOfLines: 0))
        let descriptionContent = EKProperty.LabelContent(text: description, style: .init(font: UIFont.systemFont(ofSize: 18, weight: .medium), color: descriptionColor, alignment: image != nil ? .left : .center, numberOfLines: 0))
        
        // Display an image, if there is one
        let imageContent:EKProperty.ImageContent? = image != nil ? EKProperty.ImageContent(image: (image!.circleMasked?.resizeTo(rect: CGRect(x: 0, y: 0, width: 70, height: 70)))!) : nil
        
        // Instantiate a simple message and wrap it into a notification
        let simpleMessage:EKSimpleMessage = EKSimpleMessage(image: imageContent, title: titleContent, description: descriptionContent)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        
        // Display the notification
        SwiftEntryKit.display(entry: EKNotificationMessageView(with: notificationMessage), using: attributes)
    }
    
    /// Display plain toast/popup message. This should only be used for statements, not prompts.
    func showAlert(title:String, description:String, buttons:[EntryButton], titleColor:UIColor = Color.offWhite, descriptionColor:UIColor = Color.gray, position:EKAttributes.Position, duration:Double = .infinity, image:UIImage?) {
        
        // Set Duration
        self.attributes.displayDuration = duration
        
        // Set background color and position
        self.attributes.position = position
        
        //
        // MARK: - Toast-specific settings below
        //
        
        // Create content containers for text strings
        let titleContent = EKProperty.LabelContent(text: title, style: .init(font: UIFont.systemFont(ofSize: 24, weight: .heavy), color: titleColor, alignment: image != nil && position != .center ? .left : .center, numberOfLines: 0))
        let descriptionContent = EKProperty.LabelContent(text: description, style: .init(font: UIFont.systemFont(ofSize: 18, weight: .medium), color: descriptionColor, alignment: image != nil && position != .center ? .left : .center, numberOfLines: 0))
        
        // Display an image, if there is one
        let imageContent:EKProperty.ImageContent? = image != nil ? EKProperty.ImageContent(image: (image!.circleMasked?.resizeTo(rect: CGRect(x: 0, y: 0, width: 70, height: 70)))!) : nil
        
        // Instantiate a simple message (that simply contains title and description)
        let simpleMessage:EKSimpleMessage = EKSimpleMessage(image: imageContent, title: titleContent, description: descriptionContent)
        
        var buttonContent:[EKProperty.ButtonContent] = []
        for button in buttons {
            buttonContent.append(EKProperty.ButtonContent(label: EKProperty.LabelContent(text: button.text, style: .init(font: UIFont.systemFont(ofSize: 24, weight: .heavy), color: button.textColor, alignment: .center)), backgroundColor: button.backgroundColor, highlightedBackgroundColor: button.backgroundColor.getHighlighted()) {
                if button.action != nil {
                    button.action!(nil)
                }
                self.dismiss()
            })
        }
        let buttonBarContent = EKProperty.ButtonBarContent(with: buttonContent, separatorColor: Color.gray, expandAnimatedly: true)
        
        // Insantiate an alert message with the buttons appended to the simple message.
        // Also, calculate the image's position based on the message's position
        let alertMessage:EKAlertMessage = EKAlertMessage(simpleMessage: simpleMessage, imagePosition: position == .center ? .top : .left, buttonBarContent: buttonBarContent)
        
        SwiftEntryKit.display(entry: EKAlertMessageView(with: alertMessage), using: attributes)
    }
    
    /// Display plain toast/popup message. This should only be used for statements, not prompts.
    /// Retrieve form field content from the returned `[EKProperty.TextFieldContent]` array.
    func showForm(title:String, fields:[EntryFormField], button:EntryButton, titleColor:UIColor = Color.offWhite, position:EKAttributes.Position, duration:Double = .infinity) {
        
        // Set Duration
        self.attributes.displayDuration = duration
        
        // Set background color and position
        self.attributes.position = position
        
        //
        // Create Fields
        //
        
        var fieldContent:[EKProperty.TextFieldContent] = []
        for field in fields {
            var f = EKProperty.TextFieldContent(placeholder: .init(text: field.placeholder, style: .init(font: UIFont.systemFont(ofSize: 18, weight: .medium), color: field.placeholderColor, alignment: .center, numberOfLines: 0)), textStyle: .init(font: UIFont.systemFont(ofSize: 18, weight: .medium), color: field.placeholderColor, alignment: .left, numberOfLines: 0))
            
            f.isSecure = field.isSecureText
            
            f.leadingImage = field.icon
            
            fieldContent.append(f)
        }
        
        //
        // Create Buttons
        //
        
        let buttonContent:EKProperty.ButtonContent = EKProperty.ButtonContent.init(label: EKProperty.LabelContent.init(text: button.text, style: .init(font: UIFont.systemFont(ofSize: 24, weight: .heavy), color: button.textColor, alignment: .center)), backgroundColor: button.backgroundColor, highlightedBackgroundColor: button.backgroundColor.getHighlighted()) {
            if button.action != nil {
                
                // Map text fields into `placeholder:output` pairs to receive output when the button is tapped
                button.action!(fieldContent.reduce([String: String]()) { (dict, field) -> [String: String] in
                    var dict = dict
                    dict[field.placeholder.text] = field.output
                    return dict
                })
                
            }
            self.dismiss()
        }
        
        // Insantiate an alert message with the buttons appended to the simple message.
        // Also, calculate the image's position based on the message's position
        let formMessage:EKFormMessageView = EKFormMessageView(with: .init(text: title, style: .init(font: UIFont.systemFont(ofSize: 24, weight: .heavy), color: titleColor, alignment: .center, numberOfLines: 0)), textFieldsContent: fieldContent, buttonContent: buttonContent)
        
        SwiftEntryKit.display(entry: formMessage, using: attributes)
    }
    
    func dismiss() -> Void {
        SwiftEntryKit.dismiss()
    }
    
}

extension EKProperty.ButtonBarContent {
    public init(with buttonContents:[EKProperty.ButtonContent], separatorColor: UIColor, buttonHeight: CGFloat = 50, expandAnimatedly: Bool) {
        self.init(with: buttonContents[0], separatorColor: separatorColor, buttonHeight: buttonHeight, expandAnimatedly: expandAnimatedly)
        self.content = buttonContents
    }
}

