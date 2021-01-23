//
//  HomeMoneyBooksView.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2021/01/04.
//

/*
 bottombarが消えるバグのせいで、
ListManagementView.swift ⇄ TypeBookDataView.swift
 で切り替えるタイミングでHomeMoneyBooksView.swiftが毎回再描画される。
 そして、@EnvironmentObjectで管理している変数は初期値に戻るため、使えない。
*/

import SwiftUI

class ManagementInformation : ObservableObject {
    @Published var regular:Int = 0
    @Published var your:Int = 0
    @Published var numberOfDisplay = [0,0,0]
    @Published var upDataSignal:Bool = false
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
            VStack{ // VStack(HStack)でまとめないと何故か表示されない
                NavigationLink(destination: ListManagementView(numberOfBooks: $managementNumber,
                                                               listViewTitle: $manualInput.managementStatus[managementNumber],
                                                               openBarcodeView: $openBarcodeScannerView,
                                                               bottomBarHidden: $viaBottomBar,
                                                               collectionCountDown: $managementInformation.upDataSignal),
                               isActive: $openManagmentList, label: {})
                managmentList
            }
        }
        .onAppear(perform: {
            //起動時、カテゴリー別の管理数をカウントする
            items.forEach {
                managementInformation.regular += Int($0.regularPrice)
                managementInformation.your += Int($0.yourValue)
                managementInformation.numberOfDisplay[Int($0.stateOfControl)] += 1
            }
        })
        .onChange(of: managementInformation.upDataSignal, perform: { update in
            // managmentListの値を更新
            managementInformation.regular = 0
            managementInformation.your = 0
            managementInformation.numberOfDisplay = [0,0,0]
            items.forEach {
                managementInformation.regular += Int($0.regularPrice)
                managementInformation.your += Int($0.yourValue)
                managementInformation.numberOfDisplay[Int($0.stateOfControl)] += 1
            }
        })
        .sheet(isPresented: $openBarcodeScannerView) {
            BarcodeScannerView(openCollectionViewNumber: $managementNumber,
                               collectionCountUp: $managementInformation.upDataSignal,
                               openBarCode: $openBarcodeScannerView)
        }
    }
    
    
    var managmentList: some View {
        Form {
            Section(header: Text("合計金額")){
                totalPriceView
            }
            Section(header: Text("マイリスト")){
                ForEach(0..<3) { category in
                    Button(action: {
                        managementNumber = category
                        openManagmentList.toggle()
                    },label:{
                        HStack {
                            Text(manualInput.managementStatus[category])
                            Spacer()
                            Text("\(managementInformation.numberOfDisplay[category])")
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
