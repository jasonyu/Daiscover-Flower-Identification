//
//  UIViewExtension.swift
//  Daiscover
//
//  Created by Reed Taylor on 9/24/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import UIKit

// ANinamtion extensions for bar to animate
extension UIView {
    func fadeIn(_ duration: TimeInterval = 0.25, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 0.25, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}
