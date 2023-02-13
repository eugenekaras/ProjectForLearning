//
//  ImagePicker.swift
//  ProjectForLearning
//
//  Created by Евгений Карась on 13.02.23.
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
     @Binding var image: Image?
     @Binding var isPresented: Bool
     
     func makeCoordinator() -> ImagePickerViewCoordinator {
         return ImagePickerViewCoordinator(image: $image, isPresented: $isPresented)
     }
     
     func makeUIViewController(context: Context) -> UIImagePickerController {
         let pickerController = UIImagePickerController()
         pickerController.sourceType = sourceType
         pickerController.delegate = context.coordinator
         return pickerController
     }

     func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

     }
}

class ImagePickerViewCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var image: Image?
    @Binding var isPresented: Bool
    
    init(image: Binding<Image?>, isPresented: Binding<Bool>) {
        self._image = image
        self._isPresented = isPresented
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.image = Image(uiImage: image)
        }
        self.isPresented = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.isPresented = false
    }
    
}

