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
        sortDescriptors: [ NSSortDescriptor(keyPath: \Books.stateOfControl, ascending: true) ],
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
    @State var coreDataID: UUID = UUID()
    
    var body: some View {
        NavigationLink(
            destination: EditBookDataView(id: $coreDataID,
                                          imageData: $coreDataImage,
                                          imageURL: $manualInput.url,
                                          title: $manualInput.title,
                                          author: $manualInput.author,
                                          regularPrice: $manualInput.regularPrice,
                                          dateOfPurchase: $manualInput.dateOfPurchase,
                                          stateOfControl: $manualInput.stateOfControl,
                                          yourValue: $manualInput.yourValue,
                                          memo: $manualInput.memo,
                                          impressions: $manualInput.impressions,
                                          favorite: $manualInput.favorite),
            isActive: $bottomBarHidden,
            label: {})
        List{
            ForEach(items) { item in
                if(item.stateOfControl == numberOfBooks){
                    Button(action: {
                        // CoreDataからデータを引き抜き、変数に入れ替える
                        (coreDataImage, coreDataID, manualInput.url, manualInput.title, manualInput.author, manualInput.dateOfPurchase, manualInput.stateOfControl ,manualInput.regularPrice,manualInput.yourValue, manualInput.memo, manualInput.impressions, manualInput.favorite)
                            = readCoreData(image: item.img!, id: item.id!, url: item.webImg ?? "", title: item.title!, author: item.author!, dateOfPurchase: item.dateOfPurchase!, stateOfController: item.stateOfControl, regularPrice: item.regularPrice, yourValue: item.yourValue, memo: item.memo!, impressions: item.impressions!, favorite: item.favorite)
                        bottomBarHidden.toggle()
                    }, label: {
                        HStack {
                            if(item.webImg?.count ?? 0 != 0){
                                WebImage(url: URL(string: item.webImg!))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height:50)
                                    //.padding(20)
                            }else{
                                Image(uiImage: (UIImage(data: item.img ?? .init(count:0)) ?? UIImage(systemName: "nosign"))!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height:50)
                                    .padding(20)
                            }
                            VStack {
                                Text(item.title!)
                                Text(item.author!)
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
            // ListManagementView ⇄ BarcodeScannerViewの入れ替えでボタンがスムーズに表示するため（ないと表示に遅延が発生する）
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
                    .onAppear(perform: {
                        print(numberOfBooks)
                    })
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
    
    
    private func readCoreData(image: Data, id: UUID, url: String, title:String, author:String, dateOfPurchase:Date, stateOfController: Int16, regularPrice:Int16, yourValue:Int16, memo:String, impressions:String, favorite:Int16)
    -> (Data, UUID, String, String,String,Date,Int,String,String,String,String,Int){
        
        var convertRegular:String = ""
        var convertYour:String = ""
        if(regularPrice > 0){
            convertRegular = String(regularPrice) + "円"
        }
        if(yourValue > 0){
            convertYour = String(yourValue) + "円"
        }
        return(image, id, url, title, author, dateOfPurchase, Int(stateOfController), convertRegular, convertYour, memo, impressions, Int(favorite))
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
