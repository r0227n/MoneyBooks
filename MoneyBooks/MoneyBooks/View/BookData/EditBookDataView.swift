

import SwiftUI
import CoreData
import SDWebImageSwiftUI

struct EditBookDataView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataProperty = DataProperty()
    @StateObject var manualInput = ManualInput()
    
    @Binding var id: UUID
    @Binding var imageData: Data
    @Binding var imageURL: String
    @Binding var title: String
    @Binding var author: String
    @Binding var regular: String
    @Binding var buy: Date
    @Binding var save: Int
    @Binding var memo: String
    @Binding var impressions: String
    @Binding var favorite: Int
    
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
                        Image(uiImage: UIImage(data: imageData)!)
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

            DatePicker("購入日", selection: $buy, displayedComponents: .date)

            Picker(selection: $save, label: Text("管理先を指定してください")) {
                ForEach(0 ..< manualInput.managementStatus.count) { num in
                    Text(manualInput.managementStatus[num])
                }
            }

        }
    }
    
    var readThroughSection: some View {
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
                                dataProperty.unfavorite = 4 - yellow
                            })
                            .foregroundColor(.yellow)
                            .padding()
                    }
                    ForEach(0..<dataProperty.unfavorite, id: \.self){ gray in
                        Image(systemName: "star.fill")
                            .onTapGesture(perform: {
                                favorite += (gray + 1)
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
                        TextEditor(text: $memo)
                    }
                    if(save == 1){
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
                (imageData, imageURL) = updateData(loadImage: dataProperty.setImage, url: imageURL)
            }
        })
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text("編集"))
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing){ // ナビゲーションバー左
                Button(action: {
                    updateItem()
                }, label: {
                    Text("更新")
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
            dataProperty.unfavorite = 5 - favorite
        })
    }
    func updateData(loadImage: UIImage?, url: String) -> (Data, String) {
        if(loadImage != nil){
            let deleteOfURL = ""
            let convertData: Data = (loadImage?.jpegData(compressionQuality: 0.80))!
            return (convertData, deleteOfURL)
        }else{
            return (imageData, url)
        }
    }
    func updateItem() {
        let fetchRequest: NSFetchRequest<Books> = Books.fetchRequest()
        fetchRequest.predicate = NSPredicate.init(format: "id=%@", id as CVarArg)
        do {
            let editItem = try self.viewContext.fetch(fetchRequest).first
            editItem?.id = id
            editItem?.webImg = imageURL
            editItem?.img = imageData
            editItem?.title = title
            editItem?.author =  author
            editItem?.regular = dataProperty.dataSetMoney(setMoney: regular)
            editItem?.buy = buy
            editItem?.save = Int16(save)
            editItem?.memo = memo
            editItem?.impressions =  impressions
            editItem?.favorite = Int16(favorite)
            try self.viewContext.save()
        } catch {
            print(error)
        }
        self.presentationMode.wrappedValue.dismiss()
    }
}







