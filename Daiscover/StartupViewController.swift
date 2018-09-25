//
//  StartupViewController.swift
//  Daiscover
//
//  Created by Reed Taylor on 9/24/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class StartupViewController: UIViewController {
    
    @IBOutlet weak var rightBar: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        rightBar.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rightBar.fadeIn()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        rightBar.fadeOut()
    }
    
}
