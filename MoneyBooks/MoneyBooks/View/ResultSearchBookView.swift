//
//  ResultSearchBookView.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2020/12/12.
//

import SwiftUI
import SDWebImageSwiftUI // ネット上の画像を取得

class ManualInput : ObservableObject {
    @Published var title: String = ""
    @Published var author: String = ""
    @Published var selection = 1
    let managementStatus = ["読破", "積み本", "欲しい本"]
    @Published var strIntSticker: String = ""
    @Published var strIntYour: String = ""
    @Published var stickerPrice: Int = 0
    @Published var yourValuePrice:  Int = 0
    @Published var evaluation: String = ""
    @Published var memo: String = ""
    @Published var impressions: String = ""
    @Published var favorite: Int = 1
    @Published var unfavorite: Int = 4

}

struct ResultSearchBookView: View {
    @StateObject var Books = GoogleBooksAPIViewModel()
    @StateObject var manulInput = ManualInput()
    @State var show = false
    //@Binding var request:String
    
    
    
    var body : some View{
//        List(Books.data){i in
//            HStack{
//                if i.imgUrl != ""{
//                  WebImage(url: URL(string: i.imgUrl)!).resizable().frame(width: 120, height: 170).cornerRadius(10) // SDWebImageのメソッド
//                }
//                else{
//                    Image(systemName: "nosign").resizable().frame(width: 120, height: 170).cornerRadius(10)
//                }
//
//                VStack(alignment: .leading, spacing: 10) {
//
//                    Text(i.title).fontWeight(.bold)
//
//                    Text(i.authors)
//
//                    Text(i.desc).font(.caption).lineLimit(4).multilineTextAlignment(.leading)
//                }
//            }.onTapGesture {
//                if(i.title != "データを手入力"){
//                    print("CoreDataに登録")
//                }else{
//                    print("手入力画面に遷移")
//                }
//            }
//        }.onAppear(perform: {
//            print("SearchNow", request)
//            Books.getData(request: request)
//        })
        typeAddBook
    }
    
    var typeAddBook : some View{
        Form {
            Section(header: Text("本のタイトル")){
                TextField("本のタイトルを入力してください", text: $manulInput.title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())  // 入力域のまわりを枠で囲む
                    .multilineTextAlignment(.center)
                    .padding()  // 余白を追加
            }
            Section(header: Text("作者")){
                TextField("作者を入力してください", text: $manulInput.author)
            }
            Section(header: Text("定価")){
                TextField("定価を入力してください", text: $manulInput.strIntSticker,
                          onEditingChanged: { begin in
                            if(manulInput.strIntSticker.count > 0){
                                manulInput.stickerPrice = Int(manulInput.strIntSticker)!
                            }
                            print(manulInput.stickerPrice)
                          })
                    .keyboardType(.numbersAndPunctuation)
            }
            Section(header: Text("メモ")){
                TextEditor(text: $manulInput.memo)
            }
            Section(header: Text("保存先を指定")){
                Picker(selection: $manulInput.selection, label: Text("管理先を指定してください")) {
                    ForEach(0 ..< manulInput.managementStatus.count) { num in
                        Text(self.manulInput.managementStatus[num])
                    }
                }.pickerStyle(SegmentedPickerStyle())
            }
            if(manulInput.selection == 0){
                Section(header: Text("あなたにとってこの本は？")){
                    HStack(spacing: 10) {
                        ForEach(0..<manulInput.favorite, id:\.self){ yellow in
                            Image(systemName: "star.fill")
                                .onTapGesture(perform: {
                                    manulInput.favorite = yellow + 1
                                    manulInput.unfavorite += (yellow + 1)
                                })
                                .foregroundColor(.yellow)
                                .padding()
                        }
                        ForEach(0..<manulInput.unfavorite, id: \.self){ gray in
                            Image(systemName: "star.fill")
                                .onTapGesture(perform: {
                                    manulInput.favorite += (gray + 1)
                                })
                                .padding()
                                .foregroundColor(.gray)
                        }
                    }
                    TextField("どれぐらいの価値ですか？", text: $manulInput.strIntYour,
                              onEditingChanged: { begin in
                                if(manulInput.strIntSticker.count > 0){
                                    manulInput.yourValuePrice = Int(manulInput.strIntYour)!
                                }
                                print(manulInput.yourValuePrice)
                              })
                        .keyboardType(.numbersAndPunctuation)
                }
                Section(header: Text("感想")){
                    TextEditor(text: $manulInput.impressions)
                }
            }
            
            Button(action: {
                print("push")
            }, label: {
                HStack {
                    Spacer()
                    Text("保存")
                    Spacer()
                }
            })
        }
    }
}

struct ResultSearchBookView_Previews: PreviewProvider {
    static var previews: some View {
//        ResultSearchBookView(request: .constant("9784061538238"))
        ResultSearchBookView()
    }
}
 
