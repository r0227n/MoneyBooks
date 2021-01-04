//
//  ContentView.swift
//  SwiftUI-BarcodeScanner
//
//  Created by Mike Jarosch on 11/27/20.
//

import SwiftUI

struct BarcodeScannerView: View {
    //@StateObject var viewModel = BarcodeScannerViewModel()
    @StateObject var requestViewModel = GoogleBooksAPIViewModel()
    @State var isbn:String?
    @State var loadingCompleted = false
    @State var scannedCode: String = "9784061538238"
    
    var body: some View {
        NavigationView {
            VStack {
                ScannerView(scannedCode: $scannedCode)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()
                    .frame(height: 60)
                NavigationLink(
                    destination: ResultSearchBookView(request: $scannedCode),
                    isActive: $loadingCompleted,
                    label: {
                        //
                    })
            }
            .navigationTitle("Barcode Scanner")
            .onChange(of: scannedCode, perform: { value in
                if(scannedCode.prefix(3) == "978"){  // BarCodeの上の段
                    loadingCompleted = true
                }else if(scannedCode.prefix(3) == "192"){  // BarCodeの下の段
                    // 値段の部分を引き抜く
                }
            })
        }
    }
}

struct BarcodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeScannerView()
    }
}
