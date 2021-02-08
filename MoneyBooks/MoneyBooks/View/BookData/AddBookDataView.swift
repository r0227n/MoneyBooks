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
    @Binding var page: String
    @Binding var savePoint: Int
    @Binding var openAdd: Bool
    
    @State var coverImage: Data = UIImage(systemName: "nosign")!.jpegData(compressionQuality: 0.80)!
    
    @FetchRequest(
        sortDescriptors: [ NSSortDescriptor(keyPath: \Books.id, ascending: true) ],
        animation: .default)
    var items: FetchedResults<Books>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                List {
                    MinimumLayout(imageData: $coverImage,
                                  imageURL: $imageURL,
                                  title: $title,
                                  author: $author,
                                  regular: $regular,
                                  buy: $manualInput.buy,
                                  save: $savePoint,
                                  page: $page,
                                  status: $manualInput.managementStatus,
                                  isShowMenu: $dataProperty.isShowMenu)
                    Section(header: Text("メモ").font(.callout)){
                        MemoField(read: $manualInput.read, memo: $manualInput.memo)
                    }
                    if(savePoint == 1){
                        ReadSection(impressions: $manualInput.impressions,
                                    favorite: $manualInput.favorite,
                                    unfavorite: $dataProperty.unfavorite)
                    }
                }
                .listStyle(SidebarListStyle())
                MenuViewWithinSafeArea(isShowMenu: $dataProperty.isShowMenu, setImage: $dataProperty.setImage,
                                       bottomSafeAreaInsets: (geometry.size.height + geometry.safeAreaInsets.bottom))
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .onChange(of: dataProperty.isShowMenu, perform: { value in
            if(value != true){
                (coverImage, imageURL) = dataProperty.updateData(loadImage: dataProperty.setImage, data: coverImage, url: imageURL)
            }
        })
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text(dataProperty.naviTitle))
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing){ // ナビゲーションバー左
                Button(action: {
                    print("toolbar",manualInput.buy)
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
        .onAppear(perform:{
            manualInput.buy = dataProperty.JapanTimeZone()
        })
    }

    func addItem() {
        withAnimation {
            let newItem = MoneyBooks.Books(context: viewContext)
            var pickedImage = dataProperty.setImage?.jpegData(compressionQuality: 0.80)  // UIImage -> Data

            if pickedImage == nil { // 画像が選択されていない場合
                pickedImage = UIImage(systemName: "nosign")!.jpegData(compressionQuality: 0.80)
            }
            newItem.id = UUID().uuidString
            newItem.webImg = imageURL
            newItem.img = pickedImage!
            newItem.title = title.count == 0 ? "不明" : title
            newItem.author =  author.count == 0 ? "不明" : author
            newItem.regular = dataProperty.dataSetMoney(setMoney: regular)
            newItem.buy = manualInput.buy
            newItem.save = Int16(savePoint)
            newItem.memo = dataProperty.memo
            newItem.impressions =  dataProperty.impressions
            newItem.favorite = Int16(dataProperty.favorite)
            newItem.page = dataProperty.insertInt16(string: page, unit: .page)
            newItem.read = dataProperty.insertInt16(string: manualInput.read, unit: .page)

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


public struct MinimumLayout: View {
    @Binding var imageData: Data
    @Binding var imageURL: String
    @Binding var title: String
    @Binding var author: String
    @Binding var regular: String
    @Binding var buy: Date
    @Binding var save: Int
    @Binding var page: String
    
    @Binding var status: [String]
    @Binding var isShowMenu: Bool
    
    public var body: some View {
        Section(header: Text("書籍情報").font(.callout)){
            HStack {
                Spacer()
                Button(action: {
                    UIApplication.shared.endEditing()
                    withAnimation {
                        isShowMenu.toggle()
                    }
                }, label: {
                    if(imageURL.count != 0){
                        WebImage(url: URL(string: imageURL)!)
                    }else{
                        Image(uiImage: UIImage(data: imageData)!)
                            .resizable()
                    }
                })
                .onAppear(perform:{
                    print("url",imageURL,imageData)
                })
                .scaledToFit()
                .frame(width: 200, height: 200, alignment: .center)
                Spacer()
            }
            Group {
                HStack {
                    Text("タイトル")
                    TextField("本のタイトルを入力してください", text: $title)
                }
                HStack {
                    Text("作者")
                    TextField("作者を入力してください", text: $author)
                }
                Group {
                    HStack {
                        Text("定価")
                        TextField("定価を入力してください", text: $regular,
                                  onEditingChanged: { begin in
                                    regular = DataProperty().checkerUnit(type: regular, unit: .money)
                              })
                    }
                    HStack {
                        Text("ページ数")
                        TextField("ページ数は？", text: $page,
                                  onEditingChanged: { begin in
                                    page = DataProperty().checkerUnit(type: page, unit: .page)
                                  })
                    }
                }
                .keyboardType(.numberPad)
            }
            .multilineTextAlignment(.trailing)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            
            DatePicker("購入日", selection: $buy, displayedComponents: .date)

            Picker(selection: $save, label: Text("管理先を指定してください")) {
                ForEach(0 ..< status.count) { num in
                    Text(status[num])
                }
            }
            .onAppear(perform:{
                print("url",imageData)
            })
        }
    }
}


public struct ReadSection: View {
    @Binding var impressions: String
    @Binding var favorite: Int
    @Binding var unfavorite: Int
    public var body: some View {
        Section(header: Text("あなたにとってこの本は？").font(.callout)){
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
        }
        Section(header: Text("感想").font(.callout)){
            TextEditor(text: $impressions)
                .frame(height: 140)
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
        }
        
    }
}
