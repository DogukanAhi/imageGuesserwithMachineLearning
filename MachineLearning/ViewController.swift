//
//  ViewController.swift
//  MachineLearning
//
//  Created by Doğukan Ahi on 28.07.2023.
//

import UIKit

import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var chosenCIImage = CIImage()
    
    @IBOutlet weak var resultlabel: UILabel!
    
    @IBOutlet weak var imageview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageview.isUserInteractionEnabled = true
        
    }

    
    
    
    @IBAction func changeClicked(_ sender: Any) { // photo library açma
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) { // görsel seçildikten sonraki fonksiyon
        
        imageview.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
        
        if let ciImage = CIImage(image: imageview.image!){
            chosenCIImage = ciImage
            
            
        }
        
        recognizeImage(image: chosenCIImage)
    }

    func recognizeImage(image: CIImage){
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model){
            
            let request = VNCoreMLRequest(model: model) { (VNRequest,error) in // request oluşturma
                
                if let results = VNRequest.results as? [VNClassificationObservation] { // sonucu cast ediyoruz istediği tipe göre
                    
                    let topResult = results.first // ilk sonuç en doğrusu olduğu için dizideki ilk sonucu alıyoruz
                    
                    DispatchQueue.main.async { // async olarak mainde yapıyoruz kilitlenmesin diye
                        let confidenceLabel = (topResult?.confidence ?? 0) * 100
                        let rounded = Int(confidenceLabel * 100) / 100 // virgüllü olmasın diye
                        self.resultlabel.text = "Confidence% \(rounded) It's \(topResult!.identifier)"
                        
                        
                    }
                    
                    
                }
                
                
                
            }
            
            let handler = VNImageRequestHandler(ciImage: image) // handler oluştuma
            DispatchQueue.global(qos: .userInteractive).async { // globalde yapmamızın sebebi high priority istemesi
                do {
                     try handler.perform([request]) // requesti performlamak
                    
                }catch{
                    print("Error occured")
                }
                
            }
            
        }
        
    }
    
}

