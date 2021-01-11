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
    @State var argTitle: String = "手入力"
    @State var addTypBookDataView:Bool = false
    @Binding var openCollectionViewNumber:Int
    @Binding var collectionCountUp: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                ScannerView(scannedCode: $scannedCode)
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)    //すべてのセーフエリアを無視
                NavigationLink(
                    destination: ResultSearchBookView(argResultNaviTitle: $argTitle,
                                                      request: $scannedCode),
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
                if(argTitle.count < 1){
                    collectionCountUp.toggle()
                    self.presentationMode.wrappedValue.dismiss()
                }
            })
            .navigationTitle("新規追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing){ // ナビゲーションバー左
                    NavigationLink(
                        destination: TypeBookDataView(changeNaviTitle: $argTitle,
                                                      title: $manualInput.title,
                                                      author: $manualInput.author,
                                                      regularPrice: $manualInput.regularPrice,
                                                      dateOfPurchase: $manualInput.dateOfPurchase,
                                                      stateOfControl: $manualInput.stateOfControl,
                                                      yourValue: $manualInput.yourValue,
                                                      memo: $manualInput.memo,
                                                      impressions: $manualInput.impressions,
                                                      favorite: $manualInput.favorite,
                                                      unfavorite: $manualInput.unfavorite),
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
