//
//  ScannerView.swift
//  SwiftUI-BarcodeScanner
//
//  Created by Mike Jarosch on 11/27/20.
//

import SwiftUI

struct ScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        ScannerViewController(scannerDelegate: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        // Do nothing
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scannerView: self)
    }
    
    final class Coordinator: NSObject, ScannerViewControllerDelegate {
        
        private let scannerView: ScannerView
        
        init(scannerView: ScannerView) {
            self.scannerView = scannerView
        }
        
        func didFind(barcode: String) {
            // ScannerViewController.swiftで読み取ったバーコードの数値をscannedCodeに代入
            scannerView.scannedCode = barcode
        }
        
//        func didSurface(error: CameraError) {
//            
//        }
    }
    
    typealias UIViewControllerType = ScannerViewController
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView(scannedCode: .constant(""))
    }
}
