//
//  ViewController.swift
//  What's The Film?!
//
//  Created by Аня Воронцова on 05.05.2021.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,
                      UIImagePickerControllerDelegate,
                      UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionOutlet: UILabel!
    @IBOutlet weak var promoLabel: UILabel!
    @IBOutlet weak var libraryOutlet: UIButton!
    @IBOutlet weak var cameraOutlet: UIButton!
    
    
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        libraryOutlet.layer.cornerRadius = 10
        cameraOutlet.layer.cornerRadius = 10
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Couldn't convert UIImage to CIImage")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: PostersRecognitionModel().model) else {
            fatalError("Loading CoreML model failed")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            if let firstResult = results.first {
                self.descriptionOutlet.text = "Looks like \(firstResult.identifier.uppercased()) with confidence \(self.toPercent(firstResult.confidence))"

            }
            print(results)
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func toPercent(_ num: Float) -> String {
        let result = num * 100
        return "\(String(format: "%.2f", result))%"
    }
    
    
    @IBAction func cameraPressed(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        promoLabel.text = ""
    }
    
    
    @IBAction func addPressed(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        promoLabel.text = ""
    }
    
}

