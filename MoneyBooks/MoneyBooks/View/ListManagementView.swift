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
    @State var image:Data = .init(count:0)
    @StateObject var dislayStatus = DisplayStatus()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List{
            ForEach(items) { item in
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
                .onTapGesture {
                    print(item.title!)
                }
            }
            .onDelete(perform: deleteItems)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading){ // left
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
                .onEnded({ value in // end time
                    if value.startLocation.x < CGFloat(100.0){  // スワイプの開始地点が左端
                        self.presentationMode.wrappedValue.dismiss()
                    }
                })
        )
    }
    
    private func deleteItems(offsets: IndexSet) {
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

struct ListManagementView_Previews: PreviewProvider {
    static var previews: some View {
        ListManagementView()
    }
}
