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
    
    @IBOutlet weak var classificationText: UITextView!
    @IBOutlet weak var predictionView: UIImageView!
    @IBOutlet weak var leftBar: UIView!
    @IBOutlet weak var rightBar: UIView!
    
    override func viewDidLoad() { //invisible on load
        super.viewDidLoad()
        rightBar.alpha = 0
        leftBar.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) { //fade in when appearing
        super.viewDidAppear(animated)
        leftBar.fadeIn()
        rightBar.fadeIn()
    }
    
    override func viewWillDisappear(_ animated: Bool) { //fade out when leaving
        super.viewWillDisappear(animated)
        leftBar.fadeOut()
        rightBar.fadeOut()
    }
    
    func sendFlowerData(data: ClassificationViewController.FlowerData?) {
        classification = data //get FlowerData struct from classification ViewController
        cdelegate?.isClassified()
    }
    
    override func viewWillAppear(_ animated: Bool) { //Update descriptoin every time it opens
        super.viewWillAppear(animated)
        var name = "The second classification is " + (classification?.name)! + " with a chance of " + (classification?.chance)! + ". \n\n\n"
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
}

//View Controller for third view
class Flower3ViewController: UIViewController, FlowerDelegate {
    var classification: ClassificationViewController.FlowerData? //FlowerData strct
    
    @IBOutlet weak var classificationText: UITextView!
    @IBOutlet weak var predictionView: UIImageView!
    @IBOutlet weak var leftBar: UIView!
    
    override func viewDidLoad() { //invisible on load
        super.viewDidLoad()
        leftBar.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) { //fade in when appearing
        super.viewDidAppear(animated)
        leftBar.fadeIn()
    }
    
    override func viewWillDisappear(_ animated: Bool) { //fade out when leaving
        super.viewWillDisappear(animated)
        leftBar.fadeOut()
    }
    
    func sendFlowerData(data: ClassificationViewController.FlowerData?) {
        classification = data //get FlowerData struct from classification ViewController
    }
    
    override func viewWillAppear(_ animated: Bool) { //Update descriptoin every time it opens
        super.viewWillAppear(animated)
        var name = "The third classification is " + (classification?.name)! + " with a chance of " + (classification?.chance)! + ". \n\n\n"
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
}
