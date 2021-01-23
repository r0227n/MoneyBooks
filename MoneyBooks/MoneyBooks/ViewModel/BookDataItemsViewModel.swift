//
//  BookDataItems.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2021/01/23.
//

import Foundation
import SwiftUI

class DataProperty: ObservableObject {
    @Published var url: String = ""
    @Published var naviTitle: String = ""
    @Published var naviButtonTitle = ""
    @Published var title: String = ""
    @Published var author: String = ""
    @Published var regularPrice: String = ""
    @Published var dateOfPurchase: Date = Date()
    @Published var stateOfControl:Int = 0
    @Published var yourValue: String = ""
    @Published var memo: String = ""
    @Published var impressions: String = ""
    @Published var favorite: Int = 0
    @Published var unfavorite: Int = 0
    @Published var setImage: UIImage?
    @Published var coverImage: Image = Image(systemName: "nosign")
    
    func checkerYen(typeMoney:String) -> String {
        var indexOfYen = typeMoney
        while indexOfYen.hasPrefix("0") != false { // 文字列の先頭を「０以上」の数字にする
            indexOfYen = String(indexOfYen.dropFirst(1))
        }
        if(indexOfYen.contains("円")) {
            indexOfYen = String(indexOfYen.dropLast(1))
        } else if(indexOfYen.count > 0){
            indexOfYen += "円"
        }
        return indexOfYen
    }
    
    func dataSetMoney(setMoney: String) -> Int16 {
        var recordOfMoney = setMoney
        if(recordOfMoney.contains("円")){
            recordOfMoney = String(recordOfMoney.dropLast(1))
            return Int16(recordOfMoney)!
        }else{
            return 0
        }
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // select image
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        // push cansel button
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
}









