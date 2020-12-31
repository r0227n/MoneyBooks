//
//  MoneyBooksApp.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2020/12/11.
//

import SwiftUI

@main
struct MoneyBooksApp: App {
    //let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            //BarcodeScannerView()
            //LocalImageView()
            ResultSearchBookView()
        }
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
    
    }
}
