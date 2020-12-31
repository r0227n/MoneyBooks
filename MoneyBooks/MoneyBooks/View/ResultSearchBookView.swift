//
//  ResultSearchBookView.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2020/12/12.
//

import SwiftUI
import SDWebImageSwiftUI // ネット上の画像を取得
import Foundation

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
        NavigationView {
            typeAddBook
        }
        
    }
    
    var typeAddBook : some View{
        Form {
            Section(header: Text("表紙")){
                HStack {
                    Spacer()
                    LocalImageView()
                        .frame(width: 200, height: 200, alignment: .center)
                    Spacer()
                }
                TextField("本のタイトルを入力してください", text: $manulInput.title)
                TextField("作者を入力してください", text: $manulInput.author)
                
                TextField("定価を入力してください", text: $manulInput.strIntSticker,
                          onEditingChanged: { begin in
                            manulInput.strIntSticker = checkerYen(begin: begin, typeMoney: manulInput.strIntSticker)
                            
                          })
                    .keyboardType(.numbersAndPunctuation)
                Picker(selection: $manulInput.selection, label: Text("管理先を指定してください")) {
                    ForEach(0 ..< manulInput.managementStatus.count) { num in
                        Text(self.manulInput.managementStatus[num])
                    }
                }.pickerStyle(SegmentedPickerStyle())
            }
            Section(header: Text("メモ")){
                TextEditor(text: $manulInput.memo)
            }
            if(manulInput.selection == 0){
                Group {
                    Section(header: Text("感想")){
                        TextEditor(text: $manulInput.impressions)
                    }
                    Section(header: Text("あなたにとってこの本は？")){
                        HStack(spacing: 10) {
                            ForEach(0..<manulInput.favorite, id:\.self){ yellow in
                                Image(systemName: "star.fill")
                                    .onTapGesture(perform: {
                                        manulInput.favorite = yellow + 1
                                        manulInput.unfavorite = 4 - yellow
                                        print("yellow",yellow,manulInput.favorite, manulInput.unfavorite)
                                    })
                                    .foregroundColor(.yellow)
                                    .padding()
                            }
                            ForEach(0..<manulInput.unfavorite, id: \.self){ gray in
                                Image(systemName: "star.fill")
                                    .onTapGesture(perform: {
                                        print("grayBefore",gray,manulInput.favorite, manulInput.unfavorite)
                                        manulInput.favorite += (gray + 1)
                                        manulInput.unfavorite -= (gray + 1)
                                        print("grayAfter",gray,manulInput.favorite, manulInput.unfavorite)
                                    })
                                    .padding()
                                    .foregroundColor(.gray)
                            }
                        }
                        TextField("どれぐらいの価値ですか？", text: $manulInput.strIntYour,
                                  onEditingChanged: { begin in
                                    manulInput.strIntYour = checkerYen(begin: begin, typeMoney: manulInput.strIntYour)
                                  })
                            .keyboardType(.numbersAndPunctuation)
                    }
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
    
    func checkerYen(begin:Bool, typeMoney:String) -> String {
        var indexOfYen = typeMoney
        if(begin && (indexOfYen.contains("円"))) {
            indexOfYen = String(indexOfYen.dropLast(1))
        } else if(indexOfYen.count > 0){
            indexOfYen += "円"
        }
        return indexOfYen
    }
    
    func dataSetMoney(setMoney: String) -> Int {
        var recordOfMoney = setMoney
        if(recordOfMoney.contains("円")){
            recordOfMoney = String(recordOfMoney.dropLast(1))
            return Int(recordOfMoney)!
        }else{
            return 0
        }
    }
    
}


struct ResultSearchBookView_Previews: PreviewProvider {
    static var previews: some View {
        ResultSearchBookView()
    }
}
 
