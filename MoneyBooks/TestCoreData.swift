//
//  TestCoreData.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2021/01/03.
//

import SwiftUI
import CoreData

struct TestCoreData: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Books.title, ascending: true)],
        animation: .default)
    var items: FetchedResults<Books>
    
    @State var image:Data = .init(count:0)
    
    
    var body: some View { 
        List {
            ForEach(items) { item in
                HStack {
                    Image(uiImage: UIImage(data: item.img ?? self.image)!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height:200)
                    VStack{
                        Text(item.title!)
                        Text(item.author!)
                        Text("\(item.regularPrice)")
                        Text(dateFormatter(date: item.dateOfPurchase))
                        Text("\(item.stateOfControl)")
                        Text(item.memo ?? "")
                        Text(item.impressions ?? "")
                        Text("\(item.favorite)")
                        Text("\(item.yourValue)")
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
    }

    
    private func dateFormatter(date: Date?) -> String {
        print(date as Any)
        if date != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
            return formatter.string(from: date!)
        } else {
            return "不明"
        }
        
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

struct TestCoreData_Previews: PreviewProvider {
    static var previews: some View {
        TestCoreData().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
