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
            HomeMoneyBooksView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(DisplayStatus())
        }
    }
}
