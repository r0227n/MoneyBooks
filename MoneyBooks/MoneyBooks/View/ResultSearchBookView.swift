//
//  ResultSearchBookView.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2020/12/12.
//

import SwiftUI
import SDWebImageSwiftUI
import Foundation

class ManualInput : ObservableObject {
    @Published var title: String = ""
    @Published var author: String = ""
    @Published var dateOfPurchase = Date()
    @Published var stateOfControl = 1
    @Published var regularPrice: String = ""
    @Published var yourValue: String = ""
    @Published var evaluation: String = ""
    @Published var memo: String = ""
    @Published var impressions: String = ""
    @Published var favorite: Int = 1
    @Published var unfavorite: Int = 4
    
    var managementStatus = ["読破", "積み本", "欲しい本"]
}


struct ResultSearchBookView: View {
    @StateObject var Books = GoogleBooksAPIViewModel()
    
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var manualInput = ManualInput()
    @Binding var argResultNaviTitle:String
    @Binding var request:String
    
    @State var addTypeBookData:Bool = false
    var body : some View{
        NavigationLink(
            destination: TypeBookDataView(changeNaviTitle: $argResultNaviTitle,
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
            isActive: $addTypeBookData,
            label: {})
        List(Books.data){i in
            HStack{
                if i.imgUrl != ""{
                  WebImage(url: URL(string: i.imgUrl)!).resizable().frame(width: 120, height: 170).cornerRadius(10)
                }
                else{
                    Image(systemName: "nosign").resizable().frame(width: 120, height: 170).cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(i.title).fontWeight(.bold)
                    Text(i.authors)
                    Text(i.desc).font(.caption).lineLimit(4).multilineTextAlignment(.leading)
                }
            }
            .onTapGesture {
                if(i.title != "データを手入力"){
                    print("CoreDataに登録")
                }else{
                    print("手入力画面に遷移")
                }
            }
        }
        .onAppear(perform: {
            print("SearchNow", request)
            Books.getData(request: request)
            if(argResultNaviTitle.count < 1){
                self.presentationMode.wrappedValue.dismiss()
            }
        })
        .navigationTitle("検索結果")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing){ // ナビゲーションバー左
                
                Button(action: {
                    addTypeBookData.toggle()
                },label:{
                    Text("手入力")
                })
            }
        })
        .gesture(
            DragGesture(minimumDistance: 0.5, coordinateSpace: .local)
                .onEnded({ value in // end time
                    if value.startLocation.x < CGFloat(100.0){  // スワイプの開始地点が左端
                        self.presentationMode.wrappedValue.dismiss()
                    }
                })
        )
    }
}
