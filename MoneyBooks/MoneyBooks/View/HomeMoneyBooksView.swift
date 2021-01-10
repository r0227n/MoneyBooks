//
//  HomeMoneyBooksView.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2021/01/04.
//

import SwiftUI

class ManagementInformation : ObservableObject {
    @Published var regular:Int = 0
    @Published var your:Int = 0
    @Published var categoryNumber = [0,0,0]
}

struct HomeMoneyBooksView: View {
    @FetchRequest(
        sortDescriptors: [ NSSortDescriptor(keyPath: \Books.stateOfControl, ascending: true) ],
        animation: .default)
    var items: FetchedResults<Books>

    @StateObject var managementInformation = ManagementInformation()
    @StateObject var manualInput = ManualInput()
    @Binding var viaBottomBar:Bool
    @Binding var openBarcodeScannerView:Bool
    @State var managementNumber:Int = 1
    @State var openManagmentList:Bool = false
    

 
    var body: some View {
        NavigationView {
            VStack{
                NavigationLink(destination: ListManagementView(numberOfBooks: $managementNumber,
                                                               listViewTitle: $manualInput.managementStatus[managementNumber],
                                                               openBarcodeView: $openBarcodeScannerView,
                                                               bottomBarHidden: $viaBottomBar, collectionCountDown: $managementInformation.categoryNumber),
                               isActive: $openManagmentList, label: {})
                
                myList
            }
        }
        .onAppear(perform: { //起動時、カテゴリー別の管理数をカウントする
            items.forEach {
                managementInformation.regular += Int($0.regularPrice)
                managementInformation.your += Int($0.yourValue)
                managementInformation.categoryNumber[Int($0.stateOfControl)] += 1
            }
        })
        
        .sheet(isPresented: $openBarcodeScannerView) {
            BarcodeScannerView(toStart: $managementNumber, collectionCountUp: $managementInformation.categoryNumber)
        }
    }
    
    
    var myList: some View {
        Form {
            Section(header: Text("合計金額")){
                totalPriceView
            }
            Section(header: Text("マイリスト")){
                ForEach(0..<3) { num in
                    Button(action: {
                        managementNumber = num
                        openManagmentList.toggle()
                    },label:{
                        HStack {
                            Text(manualInput.managementStatus[num])
                            Spacer()
                            Text("\(managementInformation.categoryNumber[num])")
                        }
                        .padding()
                    })
                }
            }
        }
    }
        
    var totalPriceView: some View {
        Group{
            HStack {
                Text("定価の合計金額")
                Spacer()
                Text("\(managementInformation.regular)"+"円")
            }.padding()
            HStack {
                Text("価値観の合計金額")
                Spacer()
                Text("\(managementInformation.your)"+"円")
            }.padding()
        }
    }
}
