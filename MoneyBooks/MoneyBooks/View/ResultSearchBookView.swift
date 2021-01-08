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
}


struct ResultSearchBookView: View {
    @StateObject var Books = GoogleBooksAPIViewModel()
    @State var typeFlag = false
    @Binding var request:String
    @EnvironmentObject var dislayStatus: DisplayStatus
    @Environment(\.presentationMode) var presentationMode
    @StateObject var manualInput = ManualInput()
    
    var body : some View{
        NavigationLink(
            destination: TypeBookDataView(title: $manualInput.title,
                                          author: $manualInput.author,
                                          dateOfPurchase: $manualInput.dateOfPurchase,
                                          edit: $typeFlag,
                                          regularPrice: $manualInput.regularPrice,
                                          yourValue: $manualInput.yourValue,
                                          memo: $manualInput.memo,
                                          impressions: $manualInput.impressions,
                                          favorite: $manualInput.favorite,
                                          unfavorite: $manualInput.unfavorite),
            isActive: $typeFlag,
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
                    dislayStatus.closedSearchView = true
                }else{
                    print("手入力画面に遷移")
                    typeFlag = true
                }
            }
        }
        .onAppear(perform: {
            print("SearchNow", request)
            Books.getData(request: request)
            if(dislayStatus.closedSearchView != false){
                self.presentationMode.wrappedValue.dismiss()
            }
        })
        
        .navigationTitle("検索結果")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading){
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.blue)
                        Text("戻る")
                    }
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
        )    }
}
