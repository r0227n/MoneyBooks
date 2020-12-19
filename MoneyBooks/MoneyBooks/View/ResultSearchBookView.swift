//
//  ResultSearchBookView.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2020/12/12.
//

import SwiftUI
import SDWebImageSwiftUI // ネット上の画像を取得

struct ResultSearchBookView: View {
    @StateObject var Books = GoogleBooksAPIViewModel()
    @State var show = false
    @Binding var request:String
    
    var body : some View{
        List(Books.data){i in
            HStack{
                if i.imgUrl != ""{
                  WebImage(url: URL(string: i.imgUrl)!).resizable().frame(width: 120, height: 170).cornerRadius(10) // SDWebImageのメソッド
                }
                else{
                    Image(systemName: "nosign").resizable().frame(width: 120, height: 170).cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 10) {

                    Text(i.title).fontWeight(.bold)

                    Text(i.authors)

                    Text(i.desc).font(.caption).lineLimit(4).multilineTextAlignment(.leading)
                }
            }.onTapGesture {
                if(i.title != "データを手入力"){
                    print("CoreDataに登録")
                }else{
                    print("手入力画面に遷移")
                }
            }
        }.onAppear(perform: {
            print("SearchNow", request)
            Books.getData(request: request)
        })
    }
}

struct ResultSearchBookView_Previews: PreviewProvider {
    static var previews: some View {
        ResultSearchBookView(request: .constant("9784061538238"))
    }
}
 
