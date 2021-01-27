//
//  BookDataItems.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2021/01/23.
//

import Foundation
import SwiftUI

class DataProperty: ObservableObject {
    @Published var url: String = ""
    @Published var naviTitle: String = ""
    @Published var naviButtonTitle = ""
    @Published var title: String = ""
    @Published var author: String = ""
    @Published var regular: String = ""
    @Published var buy: Date = Date()
    @Published var save:Int = 0
    @Published var memo: String = ""
    @Published var impressions: String = ""
    @Published var favorite: Int = 1
    @Published var unfavorite: Int = 4
    @Published var setImage: UIImage?
    @Published var coverImage: Image = Image(systemName: "nosign")
    
    @Published var isShowMenu = false
    
    enum ChekeItem: String {
        case money = "円"
        case page = "ページ"
    }
    
    func checkerUnit(type:String, unit: ChekeItem) -> String {
        var indexOfUnit = type
        while indexOfUnit.hasPrefix("0") != false { // 文字列の先頭を「０以上」の数字にする
            indexOfUnit = String(indexOfUnit.dropFirst(1))
        }
        if(indexOfUnit.contains(unit.rawValue)) {
            indexOfUnit = String(indexOfUnit.dropLast(unit.rawValue.count))
        } else if(indexOfUnit.count > 0){
            indexOfUnit += unit.rawValue
        }
        return indexOfUnit
    }
    
    func insertInt16(string: String, unit: ChekeItem) -> Int16 {
        return Int16(checkerUnit(type: string, unit: unit)) ?? 0
    }
        
    
    func dataSetMoney(setMoney: String) -> Int16 {
        var recordOfMoney = setMoney
        if(recordOfMoney.contains("円")){
            recordOfMoney = String(recordOfMoney.dropLast(1))
            return Int16(recordOfMoney)!
        }else{
            return 0
        }
    }
}


extension UIApplication {
    // キーボードを閉じる処理
    func endEditing() {
        sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}








