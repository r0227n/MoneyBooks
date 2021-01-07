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
    
    var body: some View {
        List{
            ForEach(items) { item in
                Text(item.title!)
            }
        }
    }
}

struct ListManagementView_Previews: PreviewProvider {
    static var previews: some View {
        ListManagementView()
    }
}
