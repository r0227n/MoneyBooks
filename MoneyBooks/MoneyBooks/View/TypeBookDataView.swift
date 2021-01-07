//
//  TypeBookDataView.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2021/01/05.
//

import SwiftUI

class ManualInput : ObservableObject {
    @Published var title: String = ""
    @Published var author: String = ""
    @Published var dateOfPurchase = Date()
    @Published var stateOfControl = 1
    let managementStatus = ["読破", "積み本", "欲しい本"]
    @Published var regularPrice: String = ""
    @Published var yourValue: String = ""
    @Published var evaluation: String = ""
    @Published var memo: String = ""
    @Published var impressions: String = ""
    @Published var favorite: Int = 1
    @Published var unfavorite: Int = 4
}

struct TypeBookDataView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var manulInput = ManualInput()
    @State var setImage:UIImage?
    var body: some View {
        Form {
            Section(header: Text("表紙")){
                HStack {
                    Spacer()
                    LocalImageView(inputImage: $setImage)
                        .frame(width: 200, height: 200, alignment: .center)
                    Spacer()
                }
                TextField("本のタイトルを入力してください", text: $manulInput.title)
                TextField("作者を入力してください", text: $manulInput.author)
                
                TextField("定価を入力してください", text: $manulInput.regularPrice,
                          onEditingChanged: { begin in
                            manulInput.regularPrice = checkerYen(begin: begin, typeMoney: manulInput.regularPrice)
                            
                          })
                    .keyboardType(.numbersAndPunctuation)
                
                DatePicker("購入日", selection: $manulInput.dateOfPurchase, displayedComponents: .date)
                
                Picker(selection: $manulInput.stateOfControl, label: Text("管理先を指定してください")) {
                    ForEach(0 ..< manulInput.managementStatus.count) { num in
                        Text(self.manulInput.managementStatus[num])
                    }
                }//.pickerStyle(SegmentedPickerStyle())
            }.onAppear(perform: {
                print(manulInput.managementStatus[manulInput.stateOfControl])
                print(manulInput.stateOfControl)
            })
            Section(header: Text("メモ")){
                TextEditor(text: $manulInput.memo)
            }
            if(manulInput.stateOfControl == 0){
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
                        TextField("どれぐらいの価値ですか？", text: $manulInput.yourValue,
                                  onEditingChanged: { begin in
                                    manulInput.yourValue = checkerYen(begin: begin, typeMoney: manulInput.yourValue)
                                  })
                            .keyboardType(.numbersAndPunctuation)
                    }
                }
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing){ // ナビゲーションバー左
                Button(action: {
                    addItem()
                }, label: {
                    Text("追加")
                })
            }
        })
    }
    
    private func addItem() {
        withAnimation {
            let newItem = MoneyBooks.Books(context: viewContext)
            var pickedImage = setImage?.jpegData(compressionQuality: 0.80)  // UIImage -> Data
            
            if pickedImage == nil { // 画像が選択されていない場合
                pickedImage = UIImage(imageLiteralResourceName: "sea").jpegData(compressionQuality: 0.80)
            }
            newItem.img = pickedImage!
            newItem.title = manulInput.title
            newItem.author =  manulInput.author
            newItem.regularPrice = dataSetMoney(setMoney: manulInput.regularPrice)
            newItem.dateOfPurchase = manulInput.dateOfPurchase
            newItem.stateOfControl = Int16(manulInput.stateOfControl)
            newItem.memo = manulInput.memo
            newItem.impressions =  manulInput.impressions
            newItem.favorite = Int16(manulInput.favorite)
            newItem.yourValue = dataSetMoney(setMoney: manulInput.yourValue)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
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
    
    
    func dataSetMoney(setMoney: String) -> Int16 {
        var recordOfMoney = setMoney
        if(recordOfMoney.contains("円")){
            recordOfMoney = String(recordOfMoney.dropLast(1))
            return Int16(recordOfMoney)!
        }else{
            return 0
        }
    }
}

struct TypeBookDataView_Previews: PreviewProvider {
    static var previews: some View {
        TypeBookDataView()
    }
}
