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
    @Published var managementNumber:Int = 0
    var managementStatus = ["読破", "積み本", "欲しい本"]
}

struct HomeMoneyBooksView: View {
    @FetchRequest(
        sortDescriptors: [ NSSortDescriptor(keyPath: \Books.stateOfControl, ascending: true) ],
        animation: .default)
    var items: FetchedResults<Books>

    @EnvironmentObject var displayStatus: DisplayStatus
    
    @State var showBarCodeFlag:Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("合計金額")){
                    totalPriceView
                }
                Section(header: Text("マイリスト")){
                    NavigationLink(
                        destination: ListManagementView(numberOfBooks: $displayStatus.read,
                                                        naviTitle: $displayStatus.managementStatus[displayStatus.managementNumber]),
                        label: {
                            Button(action: {
                                    displayStatus.managementNumber = 0
                            },label:{
                                HStack {
                                    Text(displayStatus.managementStatus[0])
                                    Spacer()
                                    Text("\(displayStatus.read)")
                                }.padding()
                            })
                        })
                    NavigationLink(
                        destination: Text("積み本"),
                        label: {
                            HStack {
                                Text(displayStatus.managementStatus[1])
                                Spacer()
                                Text("\(displayStatus.buy)")
                            }.padding()
                        })
                    NavigationLink(
                        destination: Text("欲しい本"),
                        label: {
                            HStack {
                                Text(displayStatus.managementStatus[2])
                                Spacer()
                                Text("\(displayStatus.want)")
                            }.padding()
                        })
                }
            }
            .toolbar(content: {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        showBarCodeFlag.toggle()
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                        Text("書籍を追加")
                    })
                        Spacer()
                }
            })
            .sheet(isPresented: $showBarCodeFlag) {
                BarcodeScannerView()
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

struct HomeMoneyBooksView_Previews: PreviewProvider {
    static var previews: some View {
        HomeMoneyBooksView()
    }
}
