//
//  TypeBookDataView.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2021/01/05.
//

import SwiftUI
import CoreData
import SDWebImageSwiftUI

struct TypeBookDataView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var setImage:UIImage?
    @Environment(\.presentationMode) var presentationMode

    @Binding var webImg:String
    @Binding var changeNaviTitle:String
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
    @State var naviTitle:String = ""
    
    var body: some View {
        Form {
            Section(header: Text("表紙")){
                HStack {
                    Spacer()
                    if(webImg.count != 0){
                        WebImage(url: URL(string: webImg)!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200, alignment: .center)
                    }else{
                        LocalImageView(inputImage: $setImage)
                            .frame(width: 200, height: 200, alignment: .center)
                    }
                    Spacer()
                }
                TextField("本のタイトルを入力してください", text: $manualInput.title)
                TextField("作者を入力してください", text: $manualInput.author)
                
                TextField("定価を入力してください", text: $manualInput.regularPrice,
                          onEditingChanged: { begin in
                            manualInput.regularPrice = checkerYen(typeMoney: manualInput.regularPrice)
                            
                          })
                    .keyboardType(.numbersAndPunctuation)
                
                DatePicker("購入日", selection: $manualInput.dateOfPurchase, displayedComponents: .date)
                
                Picker(selection: $manualInput.stateOfControl, label: Text("管理先を指定してください")) {
                    ForEach(0 ..< manualInput.managementStatus.count) { num in
                        Text(manualInput.managementStatus[num])
                    }
                }
            }
            Section(header: Text("メモ")){
                TextEditor(text: $manualInput.memo)
            }
 
            if(manualInput.stateOfControl == 0){
                Group {
                    Section(header: Text("感想")){
                        TextEditor(text: $manualInput.impressions)
                    }
                    Section(header: Text("あなたにとってこの本は？")){
                        HStack(spacing: 10) {
                            ForEach(0..<manualInput.favorite, id:\.self){ yellow in
                                Image(systemName: "star.fill")
                                    .onTapGesture(perform: {
                                        manualInput.favorite = yellow + 1
                                        manualInput.unfavorite = 4 - yellow
                                    })
                                    .foregroundColor(.yellow)
                                    .padding()
                            }
                            ForEach(0..<manualInput.unfavorite, id: \.self){ gray in
                                Image(systemName: "star.fill")
                                    .onTapGesture(perform: {
                                        manualInput.favorite += (gray + 1)
                                        manualInput.unfavorite -= (gray + 1)
                                    })
                                    .padding()
                                    .foregroundColor(.gray)
                            }
                        }
                        TextField("どれぐらいの価値ですか？", text: $manualInput.yourValue,
                                  onEditingChanged: { begin in
                                    manualInput.yourValue = checkerYen(typeMoney: manualInput.yourValue)
                                  })
                            .keyboardType(.numbersAndPunctuation)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text(changeNaviTitle))
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing){ // ナビゲーションバー左
                Button(action: {
                    changeNaviTitle = ""
                    addItem()
                    stateOfControl = manualInput.stateOfControl
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
        .onAppear(perform: {
            if(setUpVariable != true){
                // @Bindingの値だと再描画されるため、変数を入れ替える
                (manualInput.title, manualInput.author, manualInput.regularPrice, manualInput.dateOfPurchase,manualInput.stateOfControl,manualInput.yourValue, manualInput.memo, manualInput.impressions, manualInput.favorite, manualInput.unfavorite) = replaceVariable(title: title, author: author, regularPrice: regularPrice, dateOfPurchase: dateOfPurchase, stateOfControl: stateOfControl, yourValue: yourValue, memo: memo, impressions: impressions, favorite: favorite)
            }
            setUpVariable = true
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
            newItem.title = manualInput.title
            newItem.author =  manualInput.author
            newItem.regularPrice = dataSetMoney(setMoney: manualInput.regularPrice)
            newItem.dateOfPurchase = manualInput.dateOfPurchase
            newItem.stateOfControl = Int16(manualInput.stateOfControl)
            newItem.memo = manualInput.memo
            newItem.impressions =  manualInput.impressions
            newItem.favorite = Int16(manualInput.favorite)
            newItem.yourValue = dataSetMoney(setMoney: manualInput.yourValue)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    
    
}

func replaceVariable(title:String, author:String, regularPrice:String, dateOfPurchase:Date, stateOfControl:Int ,yourValue:String, memo:String, impressions:String, favorite:Int) -> (String,String,String,Date,Int,String,String,String,Int,Int){
    return(title, author, regularPrice, dateOfPurchase, stateOfControl, yourValue, memo, impressions, favorite, (5-favorite))
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
