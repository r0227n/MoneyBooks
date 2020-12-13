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
        if(Books.data.first != nil) {
            List(Books.data){i in
                HStack{
                    if i.imgUrl != ""{
                      WebImage(url: URL(string: i.imgUrl)!).resizable().frame(width: 120, height: 170).cornerRadius(10) // SDWebImageのメソッド
                    }
                    else{
                        Image("books").resizable().frame(width: 120, height: 170).cornerRadius(10)
                    }

                    VStack(alignment: .leading, spacing: 10) {

                        Text(i.title).fontWeight(.bold)

                        Text(i.authors)

                        Text(i.desc).font(.caption).lineLimit(4).multilineTextAlignment(.leading)
                    }
                }
            }
        }else{
            Text("SearchNow")
                .onAppear(perform: {
                    print("SearchNow", request)
                    Books.getData(request: request)
                })
        }
    }
}

struct ResultSearchBookView_Previews: PreviewProvider {
    static var previews: some View {
        ResultSearchBookView(request: .constant("9784061538238"))
    }
}
