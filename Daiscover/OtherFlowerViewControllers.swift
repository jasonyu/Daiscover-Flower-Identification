//
//  Flower2ViewController.swift
//  Daiscover
//
//  Created by Reed on 8/29/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

protocol ClassifiedDelegate {
    func isClassified()
}

// View Controller for second view
class Flower2ViewController: UIViewController, FlowerDelegate {
    var classification: ClassificationViewController.FlowerData? //FlowerData struct
    var cdelegate: ClassifiedDelegate? //delegate for page view
    var predViewLocation: CGPoint? = nil //location of prediction image
    var initialPos: CGPoint? = nil //initial position for affine transformation
    
    @IBOutlet weak var classificationText: UITextView!
    @IBOutlet weak var predictionView: UIImageView!
    @IBOutlet weak var leftBar: UIView!
    @IBOutlet weak var rightBar: UIView!
    
    override func viewDidLoad() { //invisible on load
        super.viewDidLoad()
        rightBar.alpha = 0
        leftBar.alpha = 0
        predViewLocation = self.predictionView.frame.origin
    }
    
    override func viewWillDisappear(_ animated: Bool) { //fade out when leaving
        super.viewWillDisappear(animated)
        leftBar.fadeOut()
        rightBar.fadeOut()
    }
    
    func sendFlowerData(data: ClassificationViewController.FlowerData?) {
        classification = data //get FlowerData struct from classification ViewController
        cdelegate?.isClassified()
        if (classificationText != nil) {
            classificationText.setContentOffset(.zero, animated: false) //scroll back up
        }
    }
    
    override func viewWillAppear(_ animated: Bool) { //Update descriptoin every time it opens
        super.viewWillAppear(animated)
        leftBar.fadeIn()
        rightBar.fadeIn()
        var name = "The second closest classification is " + (classification?.name)! + " with a chance of " + (classification?.chance)! + ". \n\n\n"
        if (classification!.family != "") {
            name = name + "Family: " + classification!.family + "\n"
        }
        if (classification!.genus != "") {
            name = name + "Genus: " + classification!.genus + "\n"
        }
        if (classification!.species != "") {
            name = name + "Species: " + classification!.species + "\n"
        }
        let description = "\n\n" + classification!.wiki + "\n\nDesciption provided by Wikipedia."
        self.classificationText.text = name + description
        self.predictionView.image = UIImage(named: "flower photos/" + (classification?.name)! + ".jpg")
    }
    // Handles mutation of prediction images for better view
    @IBAction func pinchImage(sender: UIPinchGestureRecognizer) {
        if (sender.state == .began) { //get position of image initially
            initialPos = sender.location(in: self.view)
        }
        if (sender.state == .began || sender.state == .changed) { //starting applying transformations
            var scale = sender.scale
            let newPos = sender.location(in: self.view)
            if (scale < 1.0) {
                scale = 1.0
            }
            else if (scale > 2.5) {
                scale = 2.5
            }
            self.predictionView.transform = CGAffineTransform(scaleX: scale, y: scale).concatenating(CGAffineTransform(translationX: predViewLocation!.x + newPos.x - initialPos!.x, y: predViewLocation!.y + newPos.y - initialPos!.y))
        }
        else if (sender.state == .ended) { //animate back to original state
            UIView.animate(withDuration: 0.3, animations: {
                self.predictionView.transform = CGAffineTransform.identity
            })
        }
    }
}

//View Controller for third view
class Flower3ViewController: UIViewController, FlowerDelegate {
    var classification: ClassificationViewController.FlowerData? //FlowerData struct
    var predViewLocation: CGPoint? = nil //location of prediction image
    var initialPos: CGPoint? = nil //initial position for affine transformation
    
    @IBOutlet weak var classificationText: UITextView!
    @IBOutlet weak var predictionView: UIImageView!
    @IBOutlet weak var leftBar: UIView!
    
    override func viewDidLoad() { //invisible on load
        super.viewDidLoad()
        leftBar.alpha = 0
        predViewLocation = self.predictionView.frame.origin
    }
    
    override func viewDidAppear(_ animated: Bool) { //fade in when appearing
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) { //fade out when leaving
        super.viewWillDisappear(animated)
        leftBar.fadeOut()
    }
    
    func sendFlowerData(data: ClassificationViewController.FlowerData?) {
        classification = data //get FlowerData struct from classification ViewController
        if (classificationText != nil) {
            classificationText.setContentOffset(.zero, animated: false) //scroll back up
        }
    }
    
    override func viewWillAppear(_ animated: Bool) { //Update descriptoin every time it opens
        super.viewWillAppear(animated)
        leftBar.fadeIn()
        var name = "The third closest classification is " + (classification?.name)! + " with a chance of " + (classification?.chance)! + ". \n\n\n"
        if (classification!.family != "") {
            name = name + "Family: " + classification!.family + "\n"
        }
        if (classification!.genus != "") {
            name = name + "Genus: " + classification!.genus + "\n"
        }
        if (classification!.species != "") {
            name = name + "Species: " + classification!.species + "\n"
        }
        let description = "\n\n" + classification!.wiki + "\n\nDesciption provided by Wikipedia."
        self.classificationText.text = name + description
        self.predictionView.image = UIImage(named: "flower photos/" + (classification?.name)! + ".jpg")
    }
    // Handles mutation of prediction images for better view
    @IBAction func pinchImage(sender: UIPinchGestureRecognizer) {
        if (sender.state == .began) { //get position of image initially
            initialPos = sender.location(in: self.view)
        }
        if (sender.state == .began || sender.state == .changed) { //starting applying transformations
            var scale = sender.scale
            let newPos = sender.location(in: self.view)
            if (scale < 1.0) {
                scale = 1.0
            }
            else if (scale > 2.5) {
                scale = 2.5
            }
            self.predictionView.transform = CGAffineTransform(scaleX: scale, y: scale).concatenating(CGAffineTransform(translationX: predViewLocation!.x + newPos.x - initialPos!.x, y: predViewLocation!.y + newPos.y - initialPos!.y))
        }
        else if (sender.state == .ended) { //animate back to original state
            UIView.animate(withDuration: 0.3, animations: {
                self.predictionView.transform = CGAffineTransform.identity
            })
        }
    }
}
