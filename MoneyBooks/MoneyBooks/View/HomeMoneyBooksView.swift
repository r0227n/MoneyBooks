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
    @Published var numberOfDisplay: [Int] = [0,0,0]

    func updateNumber(){
        regular = 0
        your = 0
        numberOfDisplay = [0,0,0]
    }
}

struct HomeMoneyBooksView: View {
    @FetchRequest(
        sortDescriptors: [ NSSortDescriptor(keyPath: \Books.stateOfControl, ascending: true) ],
        animation: .default)
    var items: FetchedResults<Books>

    @StateObject var managementInformation = ManagementInformation()
    @StateObject var manualInput = ManualInput()
    @State var openBarcodeScannerView:Bool = false
    @State var managementNumber:Int = 1
    @State var openManagmentList:Bool = false
    
    var body: some View {
        NavigationView {
            VStack{ // VStack(HStack)でまとめないと何故か表示されない
                NavigationLink(destination: ListManagementView(numberOfBooks: $managementNumber,
                                                               listViewTitle: $manualInput.managementStatus[managementNumber]),
                               isActive: $openManagmentList, label: {})
                managmentList
                Spacer()
            }
            .toolbar(content: {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        openBarcodeScannerView.toggle()
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                        Text("書籍を追加")
                    })
                    Spacer()
                }
            })
            .onAppear(perform: {
                resetNumber()
            })
            .sheet(isPresented: $openBarcodeScannerView,
                   onDismiss: resetNumber,
                   content: {
                    BarcodeScannerView(openCollectionViewNumber: $managementNumber,
                                       openBarCode: $openBarcodeScannerView)
            })
        }
    }
    
    public func resetNumber(){
        managementInformation.updateNumber()
        //起動時、カテゴリー別の管理数をカウントする
        items.forEach {
            managementInformation.regular += Int($0.regularPrice)
            managementInformation.your += Int($0.yourValue)
            managementInformation.numberOfDisplay[Int($0.stateOfControl)] += 1
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
