//
//  ListManagementView.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2021/01/04.
//

import SwiftUI

struct ListManagementView: View {
    @FetchRequest(
        sortDescriptors: [ NSSortDescriptor(keyPath: \Books.stateOfControl, ascending: true) ],
        animation: .default)
    var items: FetchedResults<Books>
    @Environment(\.managedObjectContext) private var viewContext
    @State private var image:Data = .init(count:0)

    
    @Environment(\.presentationMode) var presentationMode
    @Binding var numberOfBooks:Int
    @Binding var listViewTitle:String
    @Binding var openBarcodeView:Bool
    @Binding var bottomBarHidden:Bool
    @Binding var collectionCountDown: Bool
    @StateObject var manualInput = ManualInput()
    
    @State var argListNaviTitle:String = "編集画面"
    
    var body: some View {
        NavigationLink(
            destination: TypeBookDataView(changeNaviTitle: $argListNaviTitle,
                                          title: $manualInput.title,
                                          author: $manualInput.author,
                                          regularPrice: $manualInput.regularPrice,
                                          dateOfPurchase: $manualInput.dateOfPurchase,
                                          stateOfControl: $numberOfBooks,
                                          yourValue: $manualInput.yourValue,
                                          memo: $manualInput.memo,
                                          impressions: $manualInput.impressions,
                                          favorite: $manualInput.favorite,
                                          unfavorite: $manualInput.unfavorite),
            isActive: $bottomBarHidden,
            label: {})
        List{
            ForEach(items) { item in
                if(item.stateOfControl == numberOfBooks){
                    Button(action: {
                        // CoreDataからデータを引き抜き、変数に入れ替える
                        (manualInput.title, manualInput.author, manualInput.dateOfPurchase, manualInput.regularPrice,manualInput.yourValue, manualInput.memo, manualInput.impressions, manualInput.favorite, manualInput.unfavorite)
                            = readCoreData(title: item.title!, author: item.author!, dateOfPurchase: item.dateOfPurchase!, regularPrice: item.regularPrice, yourValue: item.yourValue, memo: item.memo!, impressions: item.impressions!, favorite: item.favorite)
                        bottomBarHidden.toggle()
                    }, label: {
                        HStack {
                            Image(uiImage: UIImage(data: item.img ?? self.image)!)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height:50)
                                .padding(20)
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
        .gesture(
            DragGesture(minimumDistance: 0.5, coordinateSpace: .local)
                .onEnded({ swipe in // end time
                    if swipe.startLocation.x < CGFloat(100.0){  // スワイプの開始地点が左端
                        self.presentationMode.wrappedValue.dismiss()
                    }
                })
        )
    }
    
    
    private func readCoreData(title:String, author:String, dateOfPurchase:Date, regularPrice:Int16, yourValue:Int16, memo:String, impressions:String, favorite:Int16)
    -> (String,String,Date,String,String,String,String,Int,Int){
        
        var convertRegular:String = ""
        var convertYour:String = ""
        if(regularPrice > 0){
            convertRegular = String(regularPrice) + "円"
        }
        if(yourValue > 0){
            convertYour = String(yourValue) + "円"
        }
        return(title, author, dateOfPurchase, convertRegular, convertYour, memo, impressions, Int(favorite), (5-Int(favorite)))
    }

    
    func deleteItems(offsets: IndexSet) {
        collectionCountDown.toggle()
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
