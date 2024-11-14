//
//  TabBarViewController.swift
//  MatchEmTab
//
//  Created by Joshua Lopez on 10/31/24.
//

import UIKit

class CurvyTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change tab bar background
        tabBar.backgroundColor = .lightGray
        tabBar.isTranslucent = true
        
        tabBar.layer.cornerRadius = 20
        tabBar.layer.masksToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var tabFrame = tabBar.frame
        tabFrame.size.height = 90  // 90 Seemed like the ideal height
        tabFrame.origin.y = view.frame.height - 80  // Position above bottom for rounded effect
        tabBar.frame = tabFrame
    }
}
