import SwiftUI
import CoreData
import SDWebImageSwiftUI

// Segue ResualSearchBookDataView&BarcodeScannerView
struct AddBookDataView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataProperty = DataProperty()
    @StateObject var manualInput = ManualInput()
    
    @Binding var imageURL: String
    @Binding var title: String
    @Binding var author: String
    @Binding var regular: String
    @Binding var savePoint: Int
    @Binding var openAdd: Bool
    
    @FetchRequest(
        sortDescriptors: [ NSSortDescriptor(keyPath: \Books.id, ascending: true) ],
        animation: .default)
    var items: FetchedResults<Books>
    
    var minimumLayout: some View {
        Group {
            HStack {
                Spacer()
                Button(action: {
                    UIApplication.shared.endEditing()
                    withAnimation {
                        dataProperty.isShowMenu.toggle()
                    }
                }, label: {
                    if(imageURL.count != 0){
                        WebImage(url: URL(string: imageURL)!)
                    }else{
                        dataProperty.coverImage
                            .resizable()
                    }
                })
                .scaledToFit()
                .frame(width: 200, height: 200, alignment: .center)
                Spacer()
            }
            TextField("本のタイトルを入力してください", text: $title)
            TextField("作者を入力してください", text: $author)

            TextField("定価を入力してください", text: $regular,
                      onEditingChanged: { begin in
                        regular = dataProperty.checkerYen(typeMoney: regular)
                      })
                .keyboardType(.numbersAndPunctuation)

            DatePicker("購入日", selection: $dataProperty.buy, displayedComponents: .date)

            Picker(selection: $savePoint, label: Text("管理先を指定してください")) {
                ForEach(0 ..< manualInput.managementStatus.count) { num in
                    Text(manualInput.managementStatus[num])
                }
            }

        }
    }
    
    var readThroughSection: some View {
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
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Form {
                    Section(header: Text("表紙")){
                        minimumLayout
                    }
                    Section(header: Text("メモ")){
                        TextEditor(text: $dataProperty.memo)
                    }
                    if(savePoint == 1){
                        readThroughSection
                    }
                }
                MenuViewWithinSafeArea(isShowMenu: $dataProperty.isShowMenu, setImage: $dataProperty.setImage,
                                       bottomSafeAreaInsets: (geometry.size.height + geometry.safeAreaInsets.bottom))
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .onChange(of: dataProperty.isShowMenu, perform: { value in
            if(value != true){
                (dataProperty.coverImage, imageURL) = loadImage(loadImage: dataProperty.setImage, url: imageURL) // coverImageを更新
            }
        })
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text(dataProperty.naviTitle))
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing){ // ナビゲーションバー左
                Button(action: {
                    addItem()
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
    
    private func loadImage(loadImage: UIImage?, url: String) -> (Image, String) {
        if(loadImage != nil){
            let deleteOfURL = ""
            return (Image(uiImage: loadImage!), deleteOfURL)
        }else{
            return (Image(systemName: "nosigin"), url)
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = MoneyBooks.Books(context: viewContext)
            var pickedImage = dataProperty.setImage?.jpegData(compressionQuality: 0.80)  // UIImage -> Data

            if pickedImage == nil { // 画像が選択されていない場合
                pickedImage = UIImage(systemName: "nosign")!.jpegData(compressionQuality: 0.80)
            }
            newItem.id = UUID().uuidString
            newItem.webImg = imageURL
            newItem.img = pickedImage!
            newItem.title = title
            newItem.author =  author
            newItem.regular = dataProperty.dataSetMoney(setMoney: regular)
            newItem.buy = dataProperty.buy
            newItem.save = Int16(savePoint)
            newItem.memo = dataProperty.memo
            newItem.impressions =  dataProperty.impressions
            newItem.favorite = Int16(dataProperty.favorite)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        openAdd.toggle()
    }
}


