import UIKit
import CoreML
import Vision
import ImageIO

class ImageClassificationViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var classificationLabel: UILabel!
    @IBOutlet weak var classificationText: UITextView!
    @IBOutlet weak var predictionView: UIImageView!
    
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
        classificationLabel.text = "Indentifying Flower..."
        
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
                self.classificationLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            let classifications = results as! [VNClassificationObservation]
            if classifications.isEmpty {
                self.classificationLabel.text = "Unable to recognize flower."
            } else {
                let topClassifications = classifications.prefix(3)
                let descriptions = topClassifications.map { classification in
                    return String(format: " %@ (%.1f chance)", classification.identifier, classification.confidence * 100)
                }
                self.classificationLabel.text = "Classification:\n" + descriptions.joined(separator: "\n")
                self.classificationText.text = topClassifications[0].identifier
                self.predictionView.image = UIImage(named: "flower photos/" + topClassifications[0].identifier + ".jpg");
            }
        }
    }

    @IBAction func takePicture() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }
        let next = self.storyboard?.instantiateViewController(withIdentifier: "mainVC")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        next?.present(picker, animated: true)
    }
    
}

// Work with new image
extension ImageClassificationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image //update UI
        updateClassifications(for: image) //classify
    }
}
