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

class ClassificationViewController: UIViewController {
    
    var startup = true
    var classNum = 0
    var topClassifications: ArraySlice<VNClassificationObservation>? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (startup) {
            startup = false
            takePicture()
        }
    }
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var classificationText: UITextView!
    @IBOutlet weak var predictionView: UIImageView!
    
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
    
    func loadJSON(filename fileName: String) -> [Flower]? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(ResponseData.self, from: data)
                return jsonData.flowers
            } catch {
                print("error:\(error)")
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

    // Get classifications
    func updateClassifications(for image: UIImage) {
        classificationText.text = "Indentifying Flower..."
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    // Reveal classification in UI
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.classificationText.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            let classifications = results as! [VNClassificationObservation]
            if classifications.isEmpty {
                self.classificationText.text = "Unable to recognize flower."
            } else {
                self.topClassifications = classifications.prefix(3)
                self.classNum = 0
                self.updateDescription()
            }
        }
    }
    
    func updateDescription() {
        if classNum == 3 {
            self.classificationText.text = "No other possible classifications. Tap Wrong Flower too cycle through again."
        }
        else {
            let database = loadJSON(filename: "database")
            if classNum > 3 { classNum = 0 }
            var newText = ""
            switch classNum {
            case 0:
                newText = "Top match is "
            case 1:
                newText = "Second match is "
            case 2:
                newText = "Third match is "
            default:
                newText = ""
            }
            guard let pred = topClassifications?[classNum].identifier else {classNum = 0; return}
            let chance = String(format: "%.2f" ,topClassifications![classNum].confidence * 100) + "%"
            let predInfo = database!.filter{$0.name == pred}
            newText += pred + " with a chance of " + chance + ". " + predInfo[0].wiki
            self.classificationText.text = newText
            self.predictionView.image = UIImage(named: "flower photos/" + self.topClassifications![classNum].identifier + ".jpg")
        }
    }
    
    @IBAction func takePicture() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    
    @IBAction func goStartup() {
        startup = true
        let next = self.storyboard?.instantiateViewController(withIdentifier: "startVC")
        present(next!, animated: true, completion: nil)
    }
    
    @IBAction func wrongFlower() {
        classNum += 1
        updateDescription()
    }
}

// Work with new image
extension ClassificationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true)
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        updateClassifications(for: image) //classify
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
