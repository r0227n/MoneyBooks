//
//  TypeBookDataView.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2021/01/05.
//

import SwiftUI
import CoreData
import SDWebImageSwiftUI

class DataProperty: ObservableObject {
    @Published var img: String = ""
    @Published var naviTitle: String = ""
    @Published var naviButtonTitle = ""
    @Published var title: String = ""
    @Published var author: String = ""
    @Published var regularPrice: String = ""
    @Published var dateOfPurchase: Date = Date()
    @Published var stateOfControl:Int = 0
    @Published var yourValue: String = ""
    @Published var memo: String = ""
    @Published var impressions: String = ""
    @Published var favorite: Int = 0
    @Published var unfavorite: Int = 0
}

struct TypeBookDataView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var setImage:UIImage?
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataProperty = DataProperty()
    
    let naviTextItems: [String] = ["追加","編集"]
    
    var argumentImg: String
    var argumentNaviTitle: Int
    let argumentNaviButtonText: String
    var argumentTitle: String
    var argumentAuthor: String
    var argumentRegularPrice: String
    var argumentDateOfPurchase: Date
    var argumentStateOfControl:Int
    var argumentYourValue: String
    var argumentMemo: String
    var argumentImpressions: String
    var argumentFavorite: Int
    var argumentUnfavorite: Int
    
    // Segue BarcodeScannerView
    init(navi: Int){
        argumentImg = ""
        argumentNaviTitle = navi
        argumentNaviButtonText = "追加"
        argumentTitle = ""
        argumentAuthor = ""
        argumentRegularPrice = ""
        argumentDateOfPurchase = Date()
        argumentStateOfControl = 2
        argumentYourValue = ""
        argumentMemo = ""
        argumentImpressions = ""
        argumentFavorite = 5
        argumentUnfavorite = 0
    }
    
    // Segue ResualSearchBookDataView
    init(imageURL: String, title: String, author: String, regularPrice: String, stateOfControl: Int){
        argumentImg = imageURL
        argumentNaviTitle = 0
        argumentNaviButtonText = "追加"
        argumentTitle = title
        argumentAuthor = author
        argumentRegularPrice = regularPrice
        argumentDateOfPurchase = Date()
        argumentStateOfControl = stateOfControl
        argumentYourValue = ""
        argumentMemo = ""
        argumentImpressions = ""
        argumentFavorite = 5
        argumentUnfavorite = 0
    }
    
    // Segue ListManagementView
    init(img: String, navi: Int, title: String, author: String, regularPrice: String, dateOfPurchase: Date, stateOfControl: Int, yourValue: String, memo: String, impressions: String, favorite: Int){
        argumentImg = "" // binary dataに書き換える
        argumentNaviTitle = navi
        argumentNaviButtonText = "更新"
        argumentTitle = title
        argumentAuthor = author
        argumentRegularPrice = regularPrice
        argumentDateOfPurchase = dateOfPurchase
        argumentStateOfControl = stateOfControl
        argumentYourValue = yourValue
        argumentMemo = memo
        argumentImpressions = impressions
        argumentFavorite = favorite
        argumentUnfavorite = 5 - favorite
    }
    
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
                    if(dataProperty.img.count != 0){
                        WebImage(url: URL(string: dataProperty.img)!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200, alignment: .center)
                    }else{
                        LocalImageView(inputImage: $setImage)
                            .frame(width: 200, height: 200, alignment: .center)
                    }
                    Spacer()
                }
                TextField("本のタイトルを入力してください", text: $dataProperty.title)
                TextField("作者を入力してください", text: $dataProperty.author)
                
                TextField("定価を入力してください", text: $dataProperty.regularPrice,
                          onEditingChanged: { begin in
                            dataProperty.regularPrice = checkerYen(typeMoney: dataProperty.regularPrice)
                            
                          })
                    .keyboardType(.numbersAndPunctuation)
                
                DatePicker("購入日", selection: $dataProperty.dateOfPurchase, displayedComponents: .date)
                
                Picker(selection: $dataProperty.stateOfControl, label: Text("管理先を指定してください")) {
                    ForEach(0 ..< manualInput.managementStatus.count) { num in
                        Text(manualInput.managementStatus[num])
                    }
                }
            }
            Section(header: Text("メモ")){
                TextEditor(text: $dataProperty.memo)
            }
 
            if(dataProperty.stateOfControl == 0){
                Group {
                    Section(header: Text("感想")){
                        TextEditor(text: $dataProperty.impressions)
                    }
                    Section(header: Text("あなたにとってこの本は？")){
                        HStack(spacing: 10) {
                            ForEach(0..<dataProperty.favorite, id:\.self){ yellow in
                                Image(systemName: "star.fill")
                                    .onTapGesture(perform: {
                                        dataProperty.favorite = yellow + 1
                                        dataProperty.unfavorite = 4 - yellow
                                    })
                                    .foregroundColor(.yellow)
                                    .padding()
                            }
                            ForEach(0..<dataProperty.unfavorite, id: \.self){ gray in
                                Image(systemName: "star.fill")
                                    .onTapGesture(perform: {
                                        dataProperty.favorite += (gray + 1)
                                        dataProperty.unfavorite -= (gray + 1)
                                    })
                                    .padding()
                                    .foregroundColor(.gray)
                            }
                        }
                        TextField("どれぐらいの価値ですか？", text: $dataProperty.yourValue,
                                  onEditingChanged: { begin in
                                    dataProperty.yourValue = checkerYen(typeMoney: dataProperty.yourValue)
                                  })
                            .keyboardType(.numbersAndPunctuation)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text(dataProperty.naviTitle))
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing){ // ナビゲーションバー左
                Button(action: {
                    if(argumentNaviTitle != 0){
                        updateItem()
                    }else{
                        addItem()
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text(dataProperty.naviButtonTitle)
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
                InitializerOfPropertyView()
            }
            setUpVariable = true
        })
    }
    
    
    private func InitializerOfPropertyView(){
        dataProperty.img = argumentImg
        dataProperty.naviTitle = naviTextItems[argumentNaviTitle]
        dataProperty.naviButtonTitle = argumentNaviButtonText
        dataProperty.title = argumentTitle
        dataProperty.author = argumentAuthor
        dataProperty.regularPrice = argumentRegularPrice
        dataProperty.dateOfPurchase = argumentDateOfPurchase
        dataProperty.stateOfControl = argumentStateOfControl
        dataProperty.yourValue = argumentYourValue
        dataProperty.memo = argumentMemo
        dataProperty.impressions = argumentImpressions
        dataProperty.favorite = argumentFavorite
        dataProperty.unfavorite = argumentUnfavorite
    }
    
    private func addItem() {
        withAnimation {
            let newItem = MoneyBooks.Books(context: viewContext)
            var pickedImage = setImage?.jpegData(compressionQuality: 0.80)  // UIImage -> Data

            if pickedImage == nil { // 画像が選択されていない場合
                pickedImage = UIImage(imageLiteralResourceName: "sea").jpegData(compressionQuality: 0.80)
            }
            newItem.img = pickedImage!
            newItem.title = dataProperty.title
            newItem.author =  dataProperty.author
            newItem.regularPrice = dataSetMoney(setMoney: dataProperty.regularPrice)
            newItem.dateOfPurchase = dataProperty.dateOfPurchase
            newItem.stateOfControl = Int16(dataProperty.stateOfControl)
            newItem.memo = dataProperty.memo
            newItem.impressions =  dataProperty.impressions
            newItem.favorite = Int16(dataProperty.favorite)
            newItem.yourValue = dataSetMoney(setMoney: dataProperty.yourValue)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func updateItem() {
        let fetchRequest: NSFetchRequest<Books> = Books.fetchRequest()
        fetchRequest.predicate = NSPredicate.init(format: "title=%@", argumentTitle)
        var pickedImage = setImage?.jpegData(compressionQuality: 0.80)  // UIImage -> Data

        if pickedImage == nil { // 画像が選択されていない場合
            pickedImage = UIImage(imageLiteralResourceName: "sea").jpegData(compressionQuality: 0.80)
        }
        do {
            let editItem = try self.viewContext.fetch(fetchRequest).first
            
            editItem?.img = pickedImage!
            editItem?.title = dataProperty.title
            editItem?.author =  dataProperty.author
            editItem?.regularPrice = dataSetMoney(setMoney: dataProperty.regularPrice)
            editItem?.dateOfPurchase = dataProperty.dateOfPurchase
            editItem?.stateOfControl = Int16(dataProperty.stateOfControl)
            editItem?.memo = dataProperty.memo
            editItem?.impressions =  dataProperty.impressions
            editItem?.favorite = Int16(dataProperty.favorite)
            editItem?.yourValue = dataSetMoney(setMoney: dataProperty.yourValue)
            try self.viewContext.save()
        } catch {
            print(error)
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
