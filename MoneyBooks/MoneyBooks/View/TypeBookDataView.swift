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


//    @Binding var webImg:String
//    @Binding var changeNaviTitle:String
//    @Binding var title: String
//    @Binding var author: String
//    @Binding var regularPrice: String
//    @Binding var dateOfPurchase: Date
//    @Binding var stateOfControl:Int
//    @Binding var yourValue: String
//    @Binding var memo: String
//    @Binding var impressions: String
//    @Binding var favorite: Int
//    @Binding var unfavorite: Int
    
    let argumentImg: String
    let argumentNavi: String
    let argumentTitle: String
    let argumentAuthor: String
    let argumentRegularPrice: String
    let argumentDateOfPurchase: Date
    let argumentStateOfControl:Int
    let argumentYourValue: String
    let argumentMemo: String
    let argumentImpressions: String
    let argumentFavorite: Int
    let argumentUnfavorite: Int
    
    
    
    @State var img: String = ""
    @State var navi: String = ""
    @State var bookTitle: String = ""
    @State var author: String = ""
    @State var regularPrice: String = ""
    @State var dateOfPurchase: Date = Date()
    @State var stateOfControl:Int = 0
    @State var yourValue: String = ""
    @State var memo: String = ""
    @State var impressions: String = ""
    @State var favorite: Int = 0
    @State var unfavorite: Int = 0
    
    init(webImg: String, changeNaviTitle: String, title: String, author: String, regularPrice: String,
         dateOfPurchase: Date, stateOfControl: Int, yourValue: String, memo: String, impressions: String, favorite: Int, unfavorite: Int){
        argumentImg = webImg
        argumentNavi = changeNaviTitle
        argumentTitle = title
        argumentAuthor = author
        argumentRegularPrice = regularPrice
        argumentDateOfPurchase = dateOfPurchase
        argumentStateOfControl = stateOfControl
        argumentYourValue = yourValue
        argumentMemo = memo
        argumentImpressions = impressions
        argumentFavorite = favorite
        argumentUnfavorite = unfavorite
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
                    if(img.count != 0){
                        WebImage(url: URL(string: img)!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200, alignment: .center)
                    }else{
                        LocalImageView(inputImage: $setImage)
                            .frame(width: 200, height: 200, alignment: .center)
                    }
                    Spacer()
                }
                TextField("本のタイトルを入力してください", text: $bookTitle)
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
        .navigationBarTitle(Text(navi))
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing){ // ナビゲーションバー左
                Button(action: {
                    navi = ""
                    //addItem()
                    updateItem()
                    //stateOfControl = manualInput.stateOfControl
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
                Stateinitializer()
                // @Bindingの値だと再描画されるため、変数を入れ替える
//                (manualInput.title, manualInput.author, manualInput.regularPrice, manualInput.dateOfPurchase,manualInput.stateOfControl,manualInput.yourValue, manualInput.memo, manualInput.impressions, manualInput.favorite, manualInput.unfavorite) = replaceVariable(title: title, author: author, regularPrice: regularPrice, dateOfPurchase: dateOfPurchase, stateOfControl: stateOfControl, yourValue: yourValue, memo: memo, impressions: impressions, favorite: favorite)
            }
            setUpVariable = true
        })
    }
    
    private func Stateinitializer(){
        img = argumentImg
        navi = argumentNavi
        bookTitle = argumentTitle
        author = argumentAuthor
        regularPrice = argumentRegularPrice
        dateOfPurchase = argumentDateOfPurchase
        stateOfControl = argumentStateOfControl
        yourValue = argumentYourValue
        memo = argumentMemo
        impressions = argumentImpressions
        favorite = argumentFavorite
        unfavorite = argumentUnfavorite
    }
    
    private func addItem() {
        withAnimation {
            let newItem = MoneyBooks.Books(context: viewContext)
            var pickedImage = setImage?.jpegData(compressionQuality: 0.80)  // UIImage -> Data

            if pickedImage == nil { // 画像が選択されていない場合
                pickedImage = UIImage(imageLiteralResourceName: "sea").jpegData(compressionQuality: 0.80)
            }
            newItem.img = pickedImage!
            newItem.title = bookTitle
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
            editItem?.title = bookTitle
            editItem?.author =  author
            editItem?.regularPrice = dataSetMoney(setMoney: regularPrice)
            editItem?.dateOfPurchase = dateOfPurchase
            editItem?.stateOfControl = Int16(stateOfControl)
            editItem?.memo = memo
            editItem?.impressions =  impressions
            editItem?.favorite = Int16(favorite)
            editItem?.yourValue = dataSetMoney(setMoney: yourValue)
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
