//
//  ClassificationViewController.swift
//  Daiscover
//
//  Created by Reed on 8/8/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ImageIO

protocol FlowerDelegate {
    func sendFlowerData(data: ClassificationViewController.FlowerData?)
}

// This view controller handles all classification and sends flower data to other controllers
class ClassificationViewController: UIViewController {
    var newPhoto = true //flag for automatically opening photo picker
    var isFlower = false //flag for classification
    var topClassifications: ArraySlice<VNClassificationObservation>? = nil //global for classifications
    var fdelegate2: FlowerDelegate? //delegate for 2nd view
    var fdelegate3: FlowerDelegate? //delegate for 3rd view
    var database: [Flower]? //used for loading in JSON database
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rightBar.alpha = 0 //right bar hidden until pages are in view
        leftBar.alpha = 0 //left bar will fade in
        classificationText.alpha = 0
        predictionView.alpha = 0
        database = loadJSON(filename: "database") //load JSON DB once on open
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        leftBar.fadeIn()
        if (predictionView.image != nil) {
            rightBar.fadeIn()
        }
        if (newPhoto) { //open camera automatically
            newPhoto = false
            takePicture()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        leftBar.fadeOut()
        rightBar.fadeOut()
    }
    
    //UI elements
    @IBOutlet weak var classificationText: UITextView!
    @IBOutlet weak var predictionView: UIImageView!
    @IBOutlet weak var rightBar: UIView!
    @IBOutlet weak var leftBar: UIView!
    
    // Structs for loading and storing Flower data from database
    struct ResponseData: Decodable {
        var flowers: [Flower]
    }
    struct Flower : Decodable {
        var name: String
        var family: String
        var genus: String
        var species: String
        var wiki: String
    }
    struct FlowerData {
        var name: String
        var chance: String
        var family: String
        var genus: String
        var species: String
        var wiki: String
    }
    
    func loadJSON(filename fileName: String) -> [Flower]? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(ResponseData.self, from: data)
                return jsonData.flowers
            } catch {
                print("Failed to load flower description:\(error)")
            }
        }
        return nil
    }
    
    // Create a request through FlowerClass Model
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: FlowerClass().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    // Create a request through FlowerOrNot Model
    lazy var isFlowerRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: FlowerOrNot().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processIsFlower(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()

    // Get classifications
    func updateClassifications(for image: UIImage) {
        classificationText.text = "Indentifying Flower..."
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.isFlowerRequest]) //first perform isFlower request
                if (self.isFlower){
                    try handler.perform([self.classificationRequest]) //if is flower then perform classification
                }
                else {
                    // Alert pop up
                    let alert = UIAlertController(title: "No flower detected", message: "Try taking a new photo or continue classifying the current photo.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                        self.takePicture()
                    }))
                    alert.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: { action in //must redefine do catch to avoid errors when trying the classification
                        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
                        do {
                            try handler.perform([self.classificationRequest]) //continue with isFlower request anyways
                        } catch {
                            print("Failed to perform classification.\n\(error.localizedDescription)")
                        }
                    }))
                    self.present(alert, animated: true)
                }
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    // Reveal classification in UI
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.classificationText.text = "Error please try again.\n\(error!.localizedDescription)"
                return
            }
            let classifications = results as! [VNClassificationObservation]
            if classifications.isEmpty {
                self.classificationText.text = "Error please try again."
            } else {
                self.topClassifications = classifications.prefix(3)
                self.updateDescription()
            }
        }
    }
    
    // Reveal classification in UI
    func processIsFlower(for request: VNRequest, error: Error?) {
        DispatchQueue.main.sync { //syncronous so that way the next classification waits
            guard let results = request.results else {
                self.classificationText.text = "Error please try again.\n\(error!.localizedDescription)"
                return
            }
            let classifications = results as! [VNClassificationObservation]
            if classifications.isEmpty {
                self.classificationText.text = "Error please try again."
            } else {
                if (classifications[0].identifier == "yes") {
                    self.isFlower = true //set flag
                }
                else {
                    self.isFlower = false //set flag
                }
            }
        }
    }
    
    // Get data from databse and load it into struct
    func getFlowerData(classNum: Int) -> FlowerData {
        let pred = topClassifications?[classNum].identifier
        var chance = ""
        if (self.isFlower){
            chance = String(format: "%.2f" ,topClassifications![classNum].confidence * 100) + "%"
        }
        else { //half as confident if not labeled as flower
            chance = String(format: "%.2f" ,topClassifications![classNum].confidence * 50) + "%"
        }
        
        let predInfo = database!.filter{$0.name == pred}
        return FlowerData(name: predInfo[0].name, chance: chance, family: predInfo[0].family, genus: predInfo[0].genus, species: predInfo[0].species, wiki: predInfo[0].wiki)
    }
    
    // Send Flower data to other views and updtae description in current view
    func updateDescription() {
        rightBar.fadeIn()
        let flower = getFlowerData(classNum: 0)
        fdelegate2?.sendFlowerData(data: getFlowerData(classNum: 1))
        fdelegate3?.sendFlowerData(data: getFlowerData(classNum: 2))
        var name = "The top classification is " + flower.name + " with a chance of " + flower.chance + ". \n\n\n"
        if (flower.family != "") {
            name = name + "Family: " + flower.family + "\n"
        }
        if (flower.genus != "") {
            name = name + "Genus: " + flower.genus + "\n"
        }
        if (flower.species != "") {
            name = name + "Species: " + flower.species + "\n"
        }
        let description = "\n\n" + flower.wiki + "\n\nDesciption provided by Wikipedia."
        self.classificationText.text = name + description
        classificationText.fadeIn()
        self.predictionView.image = UIImage(named: "flower photos/" + flower.name + ".jpg")
        predictionView.fadeIn()
    }
    
    // Open camera picker (connected to UI Button)
    @IBAction func takePicture() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true)
        rightBar.fadeIn()
    }
    
}

// Work with new image
extension ClassificationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        picker.dismiss(animated: true)
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        updateClassifications(for: image) //classify image
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
