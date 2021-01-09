//
//  MoneyBooksApp.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2020/12/11.
//

import SwiftUI

@main
struct MoneyBooksApp: App {
    let persistenceController = PersistenceController.shared
    @State var flag:Bool = false
    
    var body: some Scene {
        WindowGroup {
            HomeMoneyBooksView(test: $flag)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(DisplayStatus())
                .toolbar(content: {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button(action: {
                            flag.toggle()
                        }, label: {
                            Image(systemName: "plus.circle.fill")
                            Text("書籍を追加")
                        })
                            Spacer()
                    }
                })
        }
    }
}
