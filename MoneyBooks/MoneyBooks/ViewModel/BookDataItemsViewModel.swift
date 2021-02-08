//
//  BookDataItems.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2021/01/23.
//

import SwiftUI
import UIKit

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
    func JapanTimeZone() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")
        let now = dateFormatter.string(from: Date())
        let time:[String] = now.components(separatedBy: CharacterSet(charactersIn: " /:"))
        let calendar = Calendar(identifier: .gregorian)
        let japanCalendar = calendar.date(from: DateComponents(year: Int(time[0]), month: Int(time[1]), day: Int(time[2]), hour: Int(time[3])! + 9, minute: Int(time[4]), second: Int(time[5])))!
        return japanCalendar
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
        if((string.hasPrefix("0"+unit.rawValue) || string.count == 0)){
            return Int16(0)
        }else{
            return Int16(checkerUnit(type: string, unit: unit)) ?? Int16(string)!
        }
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
    
    func updateData(loadImage: UIImage?, data: Data, url: String) -> (Data, String) {
        if(loadImage != nil){
            let deleteOfURL = ""
            let convertData: Data = (loadImage?.jpegData(compressionQuality: 0.80))!
            return (convertData, deleteOfURL)
        }else{
            return (data, url)
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








