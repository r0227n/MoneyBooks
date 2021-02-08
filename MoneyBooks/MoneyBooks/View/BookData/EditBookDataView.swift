

import SwiftUI
import CoreData


struct EditBookDataView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataProperty = DataProperty()
    @StateObject var manualInput = ManualInput()
    
    @Binding var id: String
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
    @Binding var page: String
    @Binding var read: String
    
    @FetchRequest(
        sortDescriptors: [ NSSortDescriptor(keyPath: \Books.id, ascending: true) ],
        animation: .default)
    var items: FetchedResults<Books>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                List {
                    MinimumLayout(imageData: $imageData,
                                  imageURL: $imageURL,
                                  title: $title,
                                  author: $author,
                                  regular: $regular,
                                  buy: $buy,
                                  save: $save,
                                  page: $page,
                                  status: $manualInput.managementStatus,
                                  isShowMenu: $dataProperty.isShowMenu)
                    
                    Section(header: Text("メモ").font(.callout)){
                        MemoField(read: $read, memo: $memo)
                    }
                    if(save == 1){
                        ReadSection(impressions: $impressions, favorite: $favorite, unfavorite: $dataProperty.unfavorite)
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
                (imageData, imageURL) = dataProperty.updateData(loadImage: dataProperty.setImage,  data: imageData, url: imageURL)
            }
        })
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text("編集画面"))
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
    
    func updateItem() {
        let fetchRequest: NSFetchRequest<Books> = Books.fetchRequest()
        fetchRequest.predicate = NSPredicate.init(format: "id=%@", id)
        do {
            let editItem = try self.viewContext.fetch(fetchRequest).first
            editItem?.id = id
            editItem?.webImg = imageURL
            editItem?.img = imageData
            editItem?.title = title.count == 0 ? "不明" : title
            editItem?.author =  author.count == 0 ? "不明" : author
            editItem?.regular = dataProperty.insertInt16(string: regular, unit: .money)
            editItem?.buy = buy  
            editItem?.save = Int16(save)
            editItem?.memo = memo
            editItem?.impressions =  impressions
            editItem?.favorite = Int16(favorite)
            editItem?.page = dataProperty.insertInt16(string: page, unit: .page)
            editItem?.read = dataProperty.insertInt16(string: read, unit: .page)
            try self.viewContext.save()
        } catch {
            print(error)
        }
        self.presentationMode.wrappedValue.dismiss()
    }
}
