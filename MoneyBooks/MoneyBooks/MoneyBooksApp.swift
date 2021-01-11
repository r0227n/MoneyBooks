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
    @State var showScanner:Bool = false
    @State var bottomItem:Bool = false
    
    var body: some Scene {
        WindowGroup {
            HomeMoneyBooksView(viaBottomBar: $bottomItem, openBarcodeScannerView: $showScanner)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .toolbar(content: { // バグで(ListmanagmentView.swiftの)bottombarが消えるため、仕方なく
                    ToolbarItemGroup(placement: .bottomBar) {
                        if(bottomItem != true){
                            Button(action: {
                                showScanner.toggle()
                            }, label: {
                                Image(systemName: "plus.circle.fill")
                                Text("書籍を追加")
                            })
                            Spacer()
                        }
                    }
                })
        }
    }
}
