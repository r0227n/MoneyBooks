//
//  TypeBookDataView.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2021/01/05.
//

import SwiftUI
import CoreData

struct TypeBookDataView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var setImage:UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var title: String
    @Binding var author: String
    @Binding var regularPrice: String
    @Binding var dateOfPurchase: Date
    @Binding var stateOfControl:Int
    @Binding var yourValue: String
    @Binding var memo: String
    @Binding var impressions: String
    @Binding var favorite: Int
    @Binding var unfavorite: Int
    
    @FetchRequest(
        sortDescriptors: [ NSSortDescriptor(keyPath: \Books.stateOfControl, ascending: true) ],
        animation: .default)
    var items: FetchedResults<Books>
    
    @State private var setUpVariable:Bool = false
    @StateObject var manualInput = ManualInput()
    
    var body: some View {
        Form {
            Section(header: Text("表紙")){
                HStack {
                    Spacer()
                    LocalImageView(inputImage: $setImage)
                        .frame(width: 200, height: 200, alignment: .center)
                    Spacer()
                }
                TextField("本のタイトルを入力してください", text: $title)
                TextField("作者を入力してください", text: $author)
                
                TextField("定価を入力してください", text: $regularPrice,
                          onEditingChanged: { begin in
                            regularPrice = checkerYen(typeMoney: regularPrice)
                            
                          })
                    .keyboardType(.numbersAndPunctuation)
                
                DatePicker("購入日", selection: $dateOfPurchase, displayedComponents: .date)
                
                Picker(selection: $stateOfControl, label: Text("管理先を指定してください")) {
                    ForEach(0 ..< manualInput.managementStatus.count) { num in
                        Text(manualInput.managementStatus[num])
                    }
                }
            }
            Section(header: Text("メモ")){
                TextEditor(text: $memo)
            }
 
            if(stateOfControl == 0){
                Group {
                    Section(header: Text("感想")){
                        TextEditor(text: $impressions)
                    }
                    Section(header: Text("あなたにとってこの本は？")){
                        HStack(spacing: 10) {
                            ForEach(0..<favorite, id:\.self){ yellow in
                                Image(systemName: "star.fill")
                                    .onTapGesture(perform: {
                                        favorite = yellow + 1
                                        unfavorite = 4 - yellow
                                    })
                                    .foregroundColor(.yellow)
                                    .padding()
                            }
                            ForEach(0..<unfavorite, id: \.self){ gray in
                                Image(systemName: "star.fill")
                                    .onTapGesture(perform: {
                                        favorite += (gray + 1)
                                        unfavorite -= (gray + 1)
                                    })
                                    .padding()
                                    .foregroundColor(.gray)
                            }
                        }
                        TextField("どれぐらいの価値ですか？", text: $yourValue,
                                  onEditingChanged: { begin in
                                    yourValue = checkerYen(typeMoney: yourValue)
                                  })
                            .keyboardType(.numbersAndPunctuation)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing){ // ナビゲーションバー左
                Button(action: {
                    addItem()
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("追加")
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
    
    private func replaceVariable(title:String, author:String, regularPrice:String, dateOfPurchase:Date, stateOfControl:Int ,yourValue:String, memo:String, impressions:String, favorite:Int) -> (String,String,String,Date,Int,String,String,String,Int,Int){
        return(title, author, regularPrice, dateOfPurchase, stateOfControl, yourValue, memo, impressions, favorite, (5-favorite))
    }
    
    private func addItem() {
        withAnimation {
            let newItem = MoneyBooks.Books(context: viewContext)
            var pickedImage = setImage?.jpegData(compressionQuality: 0.80)  // UIImage -> Data

            if pickedImage == nil { // 画像が選択されていない場合
                pickedImage = UIImage(imageLiteralResourceName: "sea").jpegData(compressionQuality: 0.80)
            }
            newItem.img = pickedImage!
            newItem.title = title
            newItem.author =  author
            newItem.regularPrice = dataSetMoney(setMoney: regularPrice)
            newItem.dateOfPurchase = dateOfPurchase
            newItem.stateOfControl = Int16(stateOfControl)
            newItem.memo = memo
            newItem.impressions =  impressions
            newItem.favorite = Int16(favorite)
            newItem.yourValue = dataSetMoney(setMoney: yourValue)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    
    func checkerYen(typeMoney:String) -> String {
        var indexOfYen = typeMoney
        if(indexOfYen.contains("円")) {
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
