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

    var body: some Scene {
        WindowGroup {
//            TabView{
//                BarcodeScannerView()
//                    .tabItem { Image(systemName: "person") }
//                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
//                TestCoreData()
//                    .tabItem { Image(systemName: "book") }
//                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
//            }
             HomeMoneyBooksView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
    
    }
}
