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
    @Published var url: String = ""
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
    
    var managementStatus = ["読破", "積み本", "欲しい本"]
}


struct ResultSearchBookView: View {
    @StateObject var Books = GoogleBooksAPIViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var manualInput = ManualInput()
    
    @Binding var request:String
    @Binding var price:String
    @Binding var storage:Int
    @Binding var openResult: Bool
    
    @State var addTypeBookData:Bool = false
    var body : some View{
        NavigationLink(
            destination: AddBookDataView(imageURL: $manualInput.url,
                                         title: $manualInput.title,
                                         author: $manualInput.author,
                                         regular: $manualInput.regularPrice,
                                         savePoint: $storage,
                                         openAdd: $openResult),
            isActive: $addTypeBookData,
            label: {})
        List(Books.data){i in
            HStack{
                if i.imgUrl != ""{
                  WebImage(url: URL(string: i.imgUrl)!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 170).cornerRadius(10)
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
                manualInput.url = i.imgUrl
                manualInput.title = i.title
                manualInput.author = i.authors
                manualInput.regularPrice = DataProperty().checkerYen(typeMoney: price)
                addTypeBookData.toggle()
            }
        }
        .onAppear(perform: {
            print("SearchNow", request)
            Books.data = .init() // 検索結果を初期化
            Books.getData(request: request)
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
            ToolbarItem(placement: .cancellationAction){
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
        )
    }
}
