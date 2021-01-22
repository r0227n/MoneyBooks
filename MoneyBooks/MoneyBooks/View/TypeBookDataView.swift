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
    @Published var url: String = ""
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
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataProperty = DataProperty()
    @StateObject var manualInput = ManualInput()
    
    @State private var setImage: UIImage?
    @State private var coverImage: Image = Image(systemName: "nosign")
    var bookID: UUID?
    
    let naviTextItems: [String] = ["追加","編集"]
    var argumentURL: String?
    var argumentImage: Data?
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
    
    
    
    // Segue BarcodeScannerView
    init(navi: Int){
        argumentURL = ""
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
    }
    
    // Segue ResualSearchBookDataView
    init(imageURL: String, title: String, author: String, regularPrice: String, stateOfControl: Int){
        argumentURL = imageURL
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
    }
    
    // Segue ListManagementView
    init(img: Data, imageURL: String, navi: Int, title: String, author: String, regularPrice: String, dateOfPurchase: Date, stateOfControl: Int, yourValue: String, memo: String, impressions: String, favorite: Int, id: UUID){
        argumentImage = img
        argumentURL = imageURL
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
        bookID = id
    }
    
    @FetchRequest(
        sortDescriptors: [ NSSortDescriptor(keyPath: \Books.stateOfControl, ascending: true) ],
        animation: .default)
    var items: FetchedResults<Books>
    
    var body: some View {
        Form {
            Section(header: Text("表紙")){
                HStack {
                    Spacer()
                    NavigationLink(
                        destination:
                            ImagePicker(image: self.$setImage)
                            .navigationBarHidden(true)
                            .onDisappear(perform: {
                                loadImage() // coverImageを更新
                            })
                        ,
                        label: {
                            Group {
                                if(dataProperty.url.count != 0){
                                    WebImage(url: URL(string: dataProperty.url)!)
                                        .scaledToFit()
                                        .frame(width: 200, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                }else{
                                    coverImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                }
                            }
                        })
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
            if(dataProperty.naviTitle.count == 0){
                InitializerOfPropertyView()
            }
        })
    }
    
    private func loadImage() {
        guard let setImage = setImage else { return }
        self.coverImage = Image(uiImage: setImage)
        dataProperty.url = ""
    }
    
    private func InitializerOfPropertyView(){
        if(argumentURL?.count != 0){
            dataProperty.url = argumentURL ?? ""
        }else{
            coverImage = Image(uiImage: UIImage(data: argumentImage ?? .init(count:0))!)
        }
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
        dataProperty.unfavorite = 5 - argumentFavorite
    }
    
    private func addItem() {
        withAnimation {
            let newItem = MoneyBooks.Books(context: viewContext)
            var pickedImage = setImage?.jpegData(compressionQuality: 0.80)  // UIImage -> Data

            if pickedImage == nil { // 画像が選択されていない場合
                pickedImage = UIImage(systemName: "nosign")!.jpegData(compressionQuality: 0.80)
            }
            newItem.id = UUID()
            newItem.webImg = argumentURL
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
        fetchRequest.predicate = NSPredicate.init(format: "id=%@", bookID! as CVarArg)
        var pickedImage = setImage?.jpegData(compressionQuality: 0.80)  // UIImage -> Data
        var saveToCoredataURL:String = ""
        if pickedImage == nil { // 画像が選択されていない場合
            pickedImage = UIImage(systemName: "nosign")!.jpegData(compressionQuality: 0.80)
            saveToCoredataURL = argumentURL ?? ""
        }
        do {
            let editItem = try self.viewContext.fetch(fetchRequest).first
            editItem?.id = bookID
            editItem?.webImg = saveToCoredataURL
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

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
}

func replaceVariable(title:String, author:String, regularPrice:String, dateOfPurchase:Date, stateOfControl:Int ,yourValue:String, memo:String, impressions:String, favorite:Int) -> (String,String,String,Date,Int,String,String,String,Int){
    return(title, author, regularPrice, dateOfPurchase, stateOfControl, yourValue, memo, impressions, favorite)
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
