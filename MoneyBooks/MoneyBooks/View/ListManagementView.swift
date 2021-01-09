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
    @Binding var naviTitle:String
    @Binding var read:Int
    @Binding var buy:Int
    @Binding var want:Int
    
    var body: some View {
        List(){
            ForEach(items) { item in
                if(item.stateOfControl == numberOfBooks){
                    HStack {
                        Image(uiImage: UIImage(data: item.img ?? self.image)!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height:50)
                            .padding(20)
                        VStack {
                            Text(item.title!)
                            Text(item.author!)
                            Text("\(item.stateOfControl)")
                        }
                    }
                    .onTapGesture {
                        print(item.title!)
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(Text(naviTitle))
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
    
    private func deleteItems(offsets: IndexSet) {
        switch numberOfBooks {
        case 0:
            read -= 1
        case 1:
            buy -= 1
        case 2:
            want -= 1
        default:
            break
        }
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
