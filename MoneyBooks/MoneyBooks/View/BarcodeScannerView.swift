//
//  ContentView.swift
//  SwiftUI-BarcodeScanner
//
//  Created by Mike Jarosch on 11/27/20.
//

import SwiftUI

struct BarcodeScannerView: View {
    @StateObject var requestViewModel = GoogleBooksAPIViewModel()
    @State var isbn:String?
    @State var loadingCompleted = false
    @State var scannedCode: String = "9784061538238"
    @Environment(\.presentationMode) var presentationMode
    @StateObject var manualInput = ManualInput()
    @State var argTitle: String = "手入力画面"
    @State var addTypBookDataView:Bool = false
    @Binding var toStart:Int
    @Binding var collectionCountUp: [Int]
    
    var body: some View {
        NavigationView {
            VStack {
                ScannerView(scannedCode: $scannedCode)
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)    //すべてのセーフエリアを無視
                NavigationLink(
                    destination: ResultSearchBookView(request: $scannedCode, toStart: $toStart, typeFlag: $addTypBookDataView),
                    isActive: $loadingCompleted,
                    label: { })
            }
            .onChange(of: scannedCode, perform: { value in
                if(scannedCode.prefix(3) == "978"){  // BarCodeの上の段
                    loadingCompleted = true
                }else if(scannedCode.prefix(3) == "192"){  // BarCodeの下の段
                    // 値段の部分を引き抜く
                }
            })
            .onAppear(perform: {
                if(addTypBookDataView != false){
                    collectionCountUp[toStart] += 1
                    self.presentationMode.wrappedValue.dismiss()
                }
            })
            .navigationTitle("新規追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing){ // ナビゲーションバー左
                    NavigationLink(
                        destination: TypeBookDataView(title: $manualInput.title,
                                                      author: $manualInput.author,
                                                      regularPrice: $manualInput.regularPrice,
                                                      dateOfPurchase: $manualInput.dateOfPurchase,
                                                      stateOfControl: $toStart,
                                                      yourValue: $manualInput.yourValue,
                                                      memo: $manualInput.memo,
                                                      impressions: $manualInput.impressions,
                                                      favorite: $manualInput.favorite,
                                                      unfavorite: $manualInput.unfavorite),
                        isActive: $addTypBookDataView,
                        label: {
                            Text(argTitle)
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
