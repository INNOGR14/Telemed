//
//  RootViewController.swift
//  Telemed
//
//  Created by Macbook on 1/3/19.
//  Copyright © 2019 drsocgr14. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tabBar: UIView!
    @IBOutlet weak var leftLeftView: UIView!
    @IBOutlet weak var rightLeftView: UIView!
    @IBOutlet weak var rightRightView: UIView!
    @IBOutlet weak var leftRightView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var centerButton: UIButton!
    
    var selectBarView : UIView?
    var currentPage = 3
    var height : CGFloat = 5
    var yPosition : CGFloat = 95
    var centerWidth : CGFloat = 90
    var nonCenterWidth : CGFloat = 71.5

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        height = tabBar.frame.height / 20
        centerWidth = centerButton.frame.width
        nonCenterWidth = leftLeftView.frame.width
        yPosition = tabBar.frame.height - height

        selectBarView = UIView(frame: CGRect(x: (tabBar.frame.width - centerWidth) / 2, y: yPosition, width: centerWidth, height: height))
        selectBarView?.backgroundColor = UIColor(hexString: "#FFCC00")
        tabBar.addSubview(selectBarView!)
        tabBar.bringSubviewToFront(selectBarView!)
        
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "homePage") as! HomePageViewController
        displayContentController(destinationVC)
    }
    
    func displayContentController(_ content: UIViewController?) {
        if let content = content {
            addChild(content)
        }
        
        content?.view.frame = containerView.frame
        
        containerView.addSubview((content?.view)!)
        content?.didMove(toParent: self)
    }
    
    @IBAction func barButtons(sender: UIButton) {
        let currentVC = children.last
        var finalVC : UIViewController?
        
        switch sender.tag {
        case 1:
            finalVC = storyboard?.instantiateViewController(withIdentifier: "connect") as! ConnectViewController
        case 2:
            finalVC = storyboard?.instantiateViewController(withIdentifier: "tracker") as! TrackerViewController
        case 3:
            finalVC = storyboard?.instantiateViewController(withIdentifier: "homePage") as! HomePageViewController
        case 4:
            finalVC = storyboard?.instantiateViewController(withIdentifier: "faq") as! FAQViewController
        case 5:
            finalVC = storyboard?.instantiateViewController(withIdentifier: "settings") as! SettingsViewController
        default:
            print("hello")
        }
        
        
        if finalVC != nil && currentVC != nil{
            if finalVC != currentVC {
                if currentPage != sender.tag {
                    let forward = currentPage < sender.tag
                    currentPage = sender.tag
                    cycle(from: currentVC, to: finalVC, forward: forward)
                    animateSelectBar(currentPage)
                }
            }
        }
    }


    
    func cycle(from oldVC: UIViewController?, to newVC: UIViewController?, forward: Bool) {
        // Prepare the two view controllers for the change.
        oldVC?.willMove(toParent: nil)
        if let newVC = newVC {
            addChild(newVC)
        }

        // Get the start frame of the new view controller and the end frame
        // for the old view controller. Both rectangles are offscreen.
        let width = CGFloat(containerView.frame.width)
        let height = CGFloat(containerView.frame.height)
        newVC?.view.frame = forward ? CGRect(x: width, y: 0, width: width, height: height) : CGRect(x: -width, y: 0, width: width, height: height)
        let endFrame: CGRect = forward ? CGRect(x: -width, y: 0, width: width, height: height) : CGRect(x: width, y: 0, width: width, height: height)

        // Queue up the transition animation.
        if let oldVC = oldVC, let newVC = newVC {
            transition(from: oldVC, to: newVC, duration: 0.25, options: [], animations: {
                // Animate the views to their final positions.
                newVC.view.frame = oldVC.view.frame
                oldVC.view.frame = endFrame
            }) { finished in
                // Remove the old view controller and send the final
                // notification to the new view controller.
                oldVC.removeFromParent()
                newVC.didMove(toParent: self)
            }
        }
    }
    
    func animateSelectBar(_ destination: Int) {
        UIView.animate(withDuration: 0.25, animations: {
            
            if destination == 3 {
                self.selectBarView!.frame = CGRect(x: (self.tabBar.frame.width - self.centerButton.frame.width) / 2, y: self.yPosition, width: self.centerWidth, height: self.height)
            }
            else {
                let width = self.leftLeftView.frame.width
                var xPosition : CGFloat = 0
                
                switch destination {
                    
                case 1:
                    xPosition = 0
                case 2:
                    xPosition = self.centerButton.frame.minX - self.nonCenterWidth
                case 4:
                    xPosition = self.centerButton.frame.maxX
                case 5:
                    xPosition = self.view.frame.maxX - self.nonCenterWidth
                default:
                    print("hello")
                }
                
                self.selectBarView!.frame = CGRect(x: xPosition, y: self.yPosition, width: width, height: self.height)
            }
            
        }, completion: nil)
    }

}

