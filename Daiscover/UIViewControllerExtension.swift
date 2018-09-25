//
//  File.swift
//  Daiscover
//
//  Created by Reed Taylor on 9/25/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import UIKit

// Extension for UI loading indicator during classification
extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        let loading = UIActivityIndicatorView.init(style: .whiteLarge)
        loading.startAnimating()
        loading.center = spinnerView.center
        DispatchQueue.main.async {
            spinnerView.addSubview(loading)
            onView.addSubview(spinnerView)
        }
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
