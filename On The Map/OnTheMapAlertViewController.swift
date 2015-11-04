//
//  OnTheMapAlertViewController.swift
//  On The Map
//
//  Created by nacho on 5/4/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

public class OnTheMapAlertViewController: UIViewController {
    
    var containerView:UIView!
    var rootViewController:UIViewController!
    var retryButton:BorderedButton?
    var retryButtonLabel:UILabel?
    var messageLabel:UILabel!
    var isAlertOpen:Bool = false
    var fontName = "Roboto-Regular"
    var closeAction:(()->Void)?
    var backgroundColor = UIColor(red: 240.0/255.0, green: 72.0/255.0, blue: 10.0/255.0, alpha: 1.0)
    
    let baseHeight:CGFloat = 70.0
    let padding:CGFloat = 10.0
    
    var viewWidth:CGFloat?
    var viewHeight:CGFloat?
    var tapRecognizer: UITapGestureRecognizer? = nil
    var shouldRetry:Bool = false
    
    public class LoginAlertViewResponder {
        
        let loginAlertView:OnTheMapAlertViewController
        
        init(loginAlertView:OnTheMapAlertViewController) {
            self.loginAlertView = loginAlertView
        }
        
        public func close() {
            self.loginAlertView.closeView(false)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    public init() {
        super.init(nibName:nil, bundle:nil)
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = UIScreen.mainScreen().bounds.size
        self.viewWidth = size.width
        self.viewHeight = (self.retryButton == nil) ? baseHeight + 8 : baseHeight + 33
        
        var yPos:CGFloat = 0.0
        let contentWidth:CGFloat = self.viewWidth!
        
        let titleString = messageLabel.text! as NSString
        let titleAttr = [NSFontAttributeName:messageLabel.font]
        
        let titleSize = CGSize(width: contentWidth, height: (self.viewHeight! + 25))
        let titleRect = titleString.boundingRectWithSize(titleSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: titleAttr, context: nil)
        yPos += padding
        self.messageLabel.frame = CGRect(x: padding * 2, y: yPos + 4, width: size.width - ((padding * 3) + 5), height: ceil(titleRect.size.height + 8))
        self.messageLabel.backgroundColor = backgroundColor
        self.messageLabel.layer.cornerRadius = 3
        self.messageLabel.layer.masksToBounds = true
        yPos += ceil(titleRect.size.height + 8)
        
        if let button = self.retryButton {
            button.frame = CGRect(x: padding * 2, y: yPos + 4, width: self.messageLabel.frame.width, height: 33)
            button.layer.cornerRadius = 2
            button.layer.masksToBounds = true
            
            self.retryButtonLabel!.frame = CGRect(x: self.padding, y: (33/2) - 12, width: self.messageLabel.frame.width - (padding * 3), height: 30)
            self.retryButtonLabel!.font = UIFont(name: self.fontName, size: 17)
            yPos += 41
        }
        
        self.containerView.frame = CGRect(x: 0, y: (self.viewHeight! - yPos)/2, width: self.viewWidth!, height: yPos)
    }
    
    public func addCloseAction(action: ()->Void) {
        self.closeAction = action
    }
    
    public func show(viewController: UIViewController, text:String, retry:Bool) -> LoginAlertViewResponder {
        self.rootViewController = viewController
        self.rootViewController.addChildViewController(self)
        self.rootViewController.view.addSubview(view)
        
        self.view.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.0)
        let textColor = UIColor.whiteColor()
        
        let size = UIScreen.mainScreen().bounds.size
        self.viewWidth = size.width
        
        self.containerView = UIView()
        self.containerView.layer.shadowOffset = CGSizeMake(3, 3)
        self.containerView.layer.shadowOpacity = 0.8
        self.containerView.layer.shadowRadius = 2
        self.containerView.layer.cornerRadius = 2
        self.view.addSubview(self.containerView!)
        
        self.messageLabel = UILabel()
        messageLabel.textColor = textColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .Center
        messageLabel.font = UIFont(name: self.fontName, size: 17)
        messageLabel.text = text
        self.containerView.addSubview(messageLabel)
        
        if (retry) {
            self.retryButton = BorderedButton()
            self.retryButton!.highlightedBackingColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
            self.retryButton!.backingColor = UIColor(red: 0.0, green: 0.298, blue: 0.686, alpha:1.0)
            self.retryButton!.backgroundColor = UIColor(red: 0.0, green: 0.298, blue: 0.686, alpha:1.0)
            self.retryButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            
            self.retryButtonLabel = UILabel()
            self.retryButtonLabel?.textColor = UIColor.whiteColor()
            self.retryButtonLabel?.numberOfLines = 1
            self.retryButtonLabel?.textAlignment = .Center
            self.retryButtonLabel?.text = "Retry"
            self.retryButton?.addSubview(self.retryButtonLabel!)
            
            self.retryButton?.addTarget(self, action: "handleRetry:", forControlEvents: UIControlEvents.TouchUpInside)
            
            self.containerView.addSubview(self.retryButton!)
        }
        
        self.view.alpha = 0
        UIView.animateWithDuration(0.2, animations: {
            self.view.alpha = 1
        })
        self.containerView.frame.origin.x = self.rootViewController.view.center.x
        self.containerView.center.y = -500
        UIView.animateWithDuration(0.5, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.containerView.center = self.rootViewController.view.center
            }, completion: { finished in
                
        })
        
        isAlertOpen = true
        return LoginAlertViewResponder(loginAlertView: self)
    }
    
    public func closeView(withCallback:Bool) {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.containerView.center.y = -(self.viewHeight! + 10)
            }, completion: { finished in
                UIView.animateWithDuration(0.1, animations: {
                    self.view.alpha = 0
                    }, completion: { finished in
                        if withCallback == true {
                            if let action = self.closeAction {
                                action()
                            }
                        }
                        self.removeView()
                })
                
        })
    }
    
    func handleRetry(button:UIButton) {
        self.shouldRetry = true
        self.closeView(true)
    }
    
    func removeView() {
        isAlertOpen = false
        self.view.removeFromSuperview()
    }
}
