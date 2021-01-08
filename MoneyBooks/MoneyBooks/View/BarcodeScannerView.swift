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
    @EnvironmentObject var displayStatus: DisplayStatus
    var body: some View {
        NavigationView {
            VStack {
                ScannerView(scannedCode: $scannedCode)
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)    //すべてのセーフエリアを無視
                NavigationLink(
                    destination: ResultSearchBookView(request: $scannedCode),
                    isActive: $loadingCompleted,
                    label: { })
            }
            .onAppear(perform: {
                if(displayStatus.closedSearchView != false){
                    displayStatus.closedSearchView = false
                    self.presentationMode.wrappedValue.dismiss()
                }
            })
            .onChange(of: scannedCode, perform: { value in
                if(scannedCode.prefix(3) == "978"){  // BarCodeの上の段
                    loadingCompleted = true
                }else if(scannedCode.prefix(3) == "192"){  // BarCodeの下の段
                    // 値段の部分を引き抜く
                }
            })
            .navigationTitle("新規追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing){ // ナビゲーションバー左
                    NavigationLink(
                        destination: TypeBookDataView(),
                        label: {
                            Text("手入力画面")
                        })
                }
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action: {
                        displayStatus.closedSearchView = false
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("キャンセル")
                    })
                }
            })
        }
    }
}

//struct BarcodeScannerView_Previews: PreviewProvider {
//    static var previews: some View {
//        BarcodeScannerView(addCount: <#Binding<Int>#>)
//    }
//}
