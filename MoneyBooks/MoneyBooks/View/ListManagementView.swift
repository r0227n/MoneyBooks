//
//  ListManagementView.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2021/01/04.
//

import SwiftUI
import SDWebImageSwiftUI

struct ListManagementView: View {
    @FetchRequest(
        sortDescriptors: [ NSSortDescriptor(keyPath: \Books.id, ascending: true) ],
        animation: .default)
    var items: FetchedResults<Books>
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var numberOfBooks:Int
    @Binding var listViewTitle:String

    @State var openBarcodeView:Bool = false
    @State var bottomBarHidden:Bool = false
    @StateObject var manualInput = ManualInput()
    
    @State var coreDataImage:Data = .init(count:0)
    @State var coreDataID: String = ""
    
    var body: some View {
        NavigationLink(
            destination: EditBookDataView(id: $coreDataID,
                                          imageData: $coreDataImage,
                                          imageURL: $manualInput.url,
                                          title: $manualInput.title,
                                          author: $manualInput.author,
                                          regular: $manualInput.regular,
                                          buy: $manualInput.buy,
                                          save: $manualInput.save,
                                          memo: $manualInput.memo,
                                          impressions: $manualInput.impressions,
                                          favorite: $manualInput.favorite,
                                          page: $manualInput.page,
                                          read: $manualInput.read),
            isActive: $bottomBarHidden,
            label: {})
        List{
            ForEach(items) { item in
                if(item.save == numberOfBooks){
                    Button(action: {
                        // CoreDataからデータを引き抜き、変数に入れ替える
                        (coreDataID,
                         coreDataImage,
                         manualInput.url,
                         manualInput.title,
                         manualInput.author,
                         manualInput.regular,
                         manualInput.buy,
                         manualInput.save,
                         manualInput.memo,
                         manualInput.impressions,
                         manualInput.favorite,
                         manualInput.page,
                         manualInput.read)
                            = ReadCoreData(id: item.id!,
                                           image: item.img!,
                                           url: item.webImg!,
                                           title: item.title!,
                                           author: item.author!,
                                           regular: item.regular,
                                           buy: item.buy!,
                                           save: item.save,
                                           memo: item.memo!,
                                           impression: item.impressions!,
                                           favorite: item.favorite,
                                           page: item.page,
                                           read: item.read)
                        bottomBarHidden.toggle()
                    }, label: {
                        HStack(spacing: 5) {
                            Group{
                                if(item.webImg?.count ?? 0 != 0){
                                    WebImage(url: URL(string: item.webImg!))
                                        .resizable()
                                }else{
                                    Image(uiImage: (UIImage(data: item.img ?? .init(count:0)) ?? UIImage(systemName: "nosign"))!)
                                        .resizable()
                                }
                            }
                            .scaledToFit()
                            .frame(width: 50, height:50)
                            .padding(20)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(item.title!)
                                    .font(.body)
                                    .underline()
                                Text(item.author!)
                                    .font(.footnote)
                            }
                        }
                    })
                }  
            }
            .onDelete(perform: deleteItems)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(Text(listViewTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading){ // navigation left
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.blue)
                        Text("リスト")
                    }
                })
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {
                    openBarcodeView.toggle()
                }, label: {
                    Image(systemName: "plus.circle.fill")
                    Text("書籍を追加")
                })
                Spacer()
            }
        })
        .sheet(isPresented: $openBarcodeView,
               content: {
                BarcodeScannerView(openCollectionViewNumber: $numberOfBooks,
                                   openBarCode: $openBarcodeView)
        })  // ← HomeMoneyBooksViewで同様の宣言を行なっているが、ここでも宣言しないとbottombarが消えるバグがある
        .gesture(
            DragGesture(minimumDistance: 0.5, coordinateSpace: .local)
                .onEnded({ swipe in // end time
                    if swipe.startLocation.x < CGFloat(100.0){  // スワイプの開始地点が左端
                        self.presentationMode.wrappedValue.dismiss()
                    }
                })
        )
    }
    
    private func ReadCoreData(id: String, image: Data, url: String, title: String, author: String, regular: Int16, buy: Date, save: Int16, memo: String, impression: String, favorite: Int16, page: Int16, read: Int16)
    ->(String, Data, String, String, String, String, Date, Int, String, String, Int, String, String) {
        let conbertRegular: String = String(regular) + "円"
        return (id, image, url, title, author, conbertRegular, buy, Int(save), memo, impression, Int(favorite), String(page)+"ページ", String(read)+"ページ")
    }

    
    func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        
    }
}
