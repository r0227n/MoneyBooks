//
//  ContentView.swift
//  SwiftUI-BarcodeScanner
//
//  Created by Mike Jarosch on 11/27/20.
//

import SwiftUI

struct BarcodeScannerView: View {
    @StateObject var requestViewModel = GoogleBooksAPIViewModel()
    @State var isbn: String  = ""
    @State var codeReadingCompleted = false
    @State var scannedCode: String = ""
    @Environment(\.presentationMode) var presentationMode
    @StateObject var manualInput = ManualInput()
    @State var argTitle: String = "手入力"
    @State var addTypBookDataView: Bool = false
    @Binding var openCollectionViewNumber: Int
    @Binding var collectionCountUp: Bool
    
    @Binding var openBarCode: Bool
    
    @State var pushNaviButton: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ScannerView(scannedCode: $scannedCode)
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)    //すべてのセーフエリアを無視
                NavigationLink(
                    destination: ResultSearchBookView(argResultNaviTitle: $argTitle,
                                                      request: $isbn,
                                                      price: $manualInput.regularPrice,
                                                      storage: $openCollectionViewNumber,
                                                      openResult: $openBarCode),
                    isActive: $codeReadingCompleted,
                    label: { })
                
                NavigationLink(
                    destination: AddBookDataView(imageURL: $manualInput.url,
                                                 title: $manualInput.title,
                                                 author: $manualInput.author,
                                                 regular: $manualInput.regularPrice,
                                                 savePoint: $manualInput.stateOfControl),
                    isActive: $pushNaviButton,
                    label: {})
                
            }
            .onChange(of: scannedCode, perform: { number in
                if((number.prefix(3) == "192") && (isbn.count > 0)){  // BarCodeの下の段
                    /*
                     値段の部分を引き抜く
                     codeReadingResult.suffix(codeReadingResult.count - 7):【書籍JAN2段フラッグ】（3桁）と【分類コード】（4桁）を削除
                     .dropLast():【チェックデジット】（1桁）を削除
                     Substring　→ String
                     */
                    manualInput.regularPrice = String(number.suffix(number.count - 7).dropLast())
                    codeReadingCompleted = true
                }else if(number.prefix(3) == "978"){  // BarCodeの上の段
                    isbn = number
                }
            })
            .onAppear(perform: {
                if(argTitle.count < 1){
                    collectionCountUp.toggle()
                    self.presentationMode.wrappedValue.dismiss()
                }
            })
            .navigationTitle("新規追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing){ // ナビゲーションバー左
                    Button(action: {
                        pushNaviButton.toggle()
                    }, label: {
                        Text("手入力画面")
                    })
                }
                ToolbarItem(placement: .cancellationAction){
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("キャンセル")
                    })
                }
            })
        }
    }
}
