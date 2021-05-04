//
//  ViewController.swift
//  Hot dog
//
//  Created by youngjun kim on 2021/05/05.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = [UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = pickedImage
            guard let ciImage = CIImage(image: pickedImage) else {
                fatalError("Contert into CIImage failed")
            }
            observe(image: ciImage)
        }
    }
    
    func observe(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: YOLOv3FP16().model) else {
            fatalError("CoreMLModel loading failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let result = request.results as? [VNClassificationObservation] else {
                fatalError("Observation failed")
            }
            
            if let itemInPicture = result.first {
                if itemInPicture.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hot dog !"
                } else {
                    self.navigationItem.title = "Not an Hot dog !"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

