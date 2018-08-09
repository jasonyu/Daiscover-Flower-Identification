//
//  StartupViewController.swift
//  Daiscover
//
//  Created by Reed on 8/8/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class StartupViewController: UIViewController {
    
    @IBAction func startButton() {
        let next = self.storyboard?.instantiateViewController(withIdentifier: "mainVC")
        present(next!, animated: true, completion: nil)
    }
    
}
