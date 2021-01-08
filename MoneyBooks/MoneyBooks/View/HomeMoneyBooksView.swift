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
    @Published var showBarCodeFlag:Bool = false
    @Published var closedSearchView:Bool = false
    let managementStatus = ["読破", "積み本", "欲しい本"]
}

struct HomeMoneyBooksView: View {
    @FetchRequest(
        sortDescriptors: [ NSSortDescriptor(keyPath: \Books.stateOfControl, ascending: true) ],
        animation: .default)
    var items: FetchedResults<Books>

    @EnvironmentObject var displayStatus: DisplayStatus
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("合計金額")){
                    totalPriceView
                }
                Section(header: Text("マイリスト")){
                    NavigationLink(
                        destination: ListManagementView(numberOfBooks: $displayStatus.read),
                        label: {
                            HStack {
                                Text(displayStatus.managementStatus[0])
                                Spacer()
                                Text("\(displayStatus.read)")
                            }.padding()
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
                        displayStatus.showBarCodeFlag.toggle()
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                        Text("書籍を追加")
                    })
                        Spacer()
                }
            })
            .sheet(isPresented: $displayStatus.showBarCodeFlag) {
                BarcodeScannerView()
            }
        }
        .onAppear(perform: {
            countUp()
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
    
    private func countUp() {
        items.forEach {
            displayStatus.regular += Int($0.regularPrice)
            displayStatus.your += Int($0.yourValue)
            switch($0.stateOfControl){
            case 1:
                displayStatus.read += Int($0.stateOfControl)
            case 2:
                displayStatus.buy += Int($0.stateOfControl)
            case 3:
                displayStatus.want += Int($0.stateOfControl)
            default:
                print("error")
            }
        }
    }
}

struct HomeMoneyBooksView_Previews: PreviewProvider {
    static var previews: some View {
        HomeMoneyBooksView()
    }
}
