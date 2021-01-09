//
//  HomeMoneyBooksView.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2021/01/04.
//

import SwiftUI

class DisplayStatus : ObservableObject {
    @Published var regular:Int = 0
    @Published var your:Int = 0
    @Published var read:Int = 0
    @Published var buy:Int = 0
    @Published var want:Int = 0
    @Published var closedSearchView:Bool = false
    @Published var openSearchView:Bool = false
    @Published var managementNumber:Int = 1
    var managementStatus = ["読破", "積み本", "欲しい本"]
}

struct HomeMoneyBooksView: View {
    @FetchRequest(
        sortDescriptors: [ NSSortDescriptor(keyPath: \Books.stateOfControl, ascending: true) ],
        animation: .default)
    var items: FetchedResults<Books>

    @EnvironmentObject var displayStatus: DisplayStatus
    
    @State var showBarCodeFlag:Bool = false
    @State var openListFlag:Bool = false
    @State private var changeNumber:Int = 0
    
    @Binding var test:Bool
    
    var body: some View {
        NavigationView {
            VStack{
                NavigationLink(destination: ListManagementView(numberOfBooks: $changeNumber,
                                                                   naviTitle: $displayStatus.managementStatus[changeNumber],
                                                                   read:$displayStatus.read,
                                                                   buy: $displayStatus.buy,
                                                                   want: $displayStatus.want),
                                   isActive: $openListFlag,
                                   label: {})
                Form {
                    Section(header: Text("合計金額")){
                        totalPriceView
                    }
                    Section(header: Text("マイリスト")){
                        Button(action: {
                            displayStatus.managementNumber = 0
                            changeNumber = 0
                            openListFlag.toggle()
                        },label:{
                            HStack {
                                Text(displayStatus.managementStatus[0])
                                Spacer()
                                Text("\(displayStatus.read)")
                            }.padding()
                        })
                        Button(action: {
                            displayStatus.managementNumber = 1
                            changeNumber = 1
                            openListFlag.toggle()
                        }, label: {
                            HStack {
                                Text(displayStatus.managementStatus[1])
                                Spacer()
                                Text("\(displayStatus.buy)")
                            }.padding()
                        })
                        Button(action: {
                            displayStatus.managementNumber = 2
                            changeNumber = 2
                            openListFlag.toggle()
                        }, label: {
                            HStack {
                                Text(displayStatus.managementStatus[2])
                                Spacer()
                                Text("\(displayStatus.want)")
                            }.padding()
                        })
                    }
                }
            }
        }
        .onAppear(perform: {
            items.forEach {
                displayStatus.regular += Int($0.regularPrice)
                displayStatus.your += Int($0.yourValue)
                switch($0.stateOfControl){
                case 0:
                    displayStatus.read += 1
                case 1:
                    displayStatus.buy += 1
                case 2:
                    displayStatus.want += 1
                default:
                    print("error")
                }
            }
        })
        .sheet(isPresented: $test) {
            BarcodeScannerView()
        }
    }
    
    var totalPriceView: some View {
        Group{
            HStack {
                Text("定価の合計金額")
                Spacer()
                Text("\(displayStatus.regular)"+"円")
            }.padding()
            HStack {
                Text("価値観の合計金額")
                Spacer()
                Text("\(displayStatus.your)"+"円")
            }.padding()
        }
    }
}
//
//struct HomeMoneyBooksView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeMoneyBooksView()
//    }
//}
