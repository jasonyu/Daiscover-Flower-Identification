//
//  PageViewController.swift
//  Daiscover
//
//  Created by Reed on 8/28/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

// Control paged layout of classifications
class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource,ClassifiedDelegate {

    var orderedViewControllers = [UIViewController]()
    var classFlag = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        
        // Instantiate view controllers for pages
        let startVC = storyboard?.instantiateViewController(withIdentifier: "startVC") as! StartupViewController
        let flowerVC1 = storyboard?.instantiateViewController(withIdentifier: "flowerVC1") as! ClassificationViewController
        let flowerVC2 = storyboard?.instantiateViewController(withIdentifier: "flowerVC2") as! Flower2ViewController
        let flowerVC3 = storyboard?.instantiateViewController(withIdentifier: "flowerVC3") as! Flower3ViewController
        
        // Declare delegates for sending data
        flowerVC1.fdelegate2 = flowerVC2
        flowerVC1.fdelegate3 = flowerVC3
        flowerVC2.cdelegate = self
        
        // Create View array
        orderedViewControllers.append(startVC)
        orderedViewControllers.append(flowerVC1)
        orderedViewControllers.append(flowerVC2)
        orderedViewControllers.append(flowerVC3)
        
        // Open first view
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    // If the first view says that there has been a classification, open up the views
    func isClassified() {
        classFlag = true
        setViewControllers([orderedViewControllers[1]], direction: .forward, animated: false, completion: nil)
    }
    
    // For page before current page
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = vcIndex - 1
        
        guard previousIndex >= 0 else {
            return nil //return nil if trying to go too far left
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    // For page after current page
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = vcIndex + 1
        
        if (classFlag == false && nextIndex == 2) {
            return nil //return nil if there hasn't been a classification
        }

        guard orderedViewControllers.count > nextIndex else {
            return nil //return nil if trying to go too far right
        }
        
        return orderedViewControllers[nextIndex]
    }
}
