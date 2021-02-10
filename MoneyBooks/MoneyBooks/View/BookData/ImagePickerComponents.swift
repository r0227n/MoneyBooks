//
//  ImagePickerComponents.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2021/01/24.
//

import SwiftUI


struct MenuViewWithinSafeArea: View {
    @Binding var isShowMenu: Bool
    @Binding var setImage: UIImage?
    let bottomSafeAreaInsets: CGFloat

    var body: some View {
        GeometryReader { geometry in
            withAnimation{
                ImagePicker(image: $setImage, isShowDown: $isShowMenu)
                    .frame(height: bottomSafeAreaInsets)
                    .edgesIgnoringSafeArea(.bottom)
                    .offset(x: 0, y: isShowMenu ? 0 : bottomSafeAreaInsets)
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    @Binding var isShowDown: Bool

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
            parent.isShowDown.toggle()
        }
        
        // push cansel button
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isShowDown.toggle()
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

