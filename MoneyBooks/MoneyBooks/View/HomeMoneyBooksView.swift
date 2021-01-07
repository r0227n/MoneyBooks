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
}


struct HomeMoneyBooksView: View {
    @FetchRequest(
        sortDescriptors: [ NSSortDescriptor(keyPath: \Books.stateOfControl, ascending: true) ],
        animation: .default)
    var items: FetchedResults<Books>
    
    @StateObject var dislayStatus = DisplayStatus()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("合計金額")){
                    totalPriceView
                }
                Section(header: Text("マイリスト")){
                    NavigationLink(
                        destination: ListManagementView(),
                        label: {
                            HStack {
                                Text("読破済み")
                                Spacer()
                                Text("\(dislayStatus.read)")
                            }.padding()
                        })
                    NavigationLink(
                        destination: Text("積み本"),
                        label: {
                            HStack {
                                Text("積み本")
                                Spacer()
                                Text("\(dislayStatus.buy)")
                            }.padding()
                        })
                    NavigationLink(
                        destination: Text("欲しい本"),
                        label: {
                            HStack {
                                Text("欲しい本")
                                Spacer()
                                Text("\(dislayStatus.want)")
                            }.padding()
                        })
                }
            }
            .onAppear(perform: {
                print(type(of: items))
                items.forEach {
                    print(type(of:$0.yourValue),$0.stateOfControl)
                    switch($0.stateOfControl){
                    case 1:
                        dislayStatus.read += Int($0.stateOfControl)
                    case 2:
                        dislayStatus.buy += Int($0.stateOfControl)
                    case 3:
                        dislayStatus.want += Int($0.stateOfControl)
                    default:
                        print("error")
                    }
                    dislayStatus.regular += Int($0.regularPrice)
                    dislayStatus.your += Int($0.yourValue)
                }
            })
            .toolbar(content: {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        dislayStatus.showBarCodeFlag.toggle()
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                        Text("書籍を追加")
                    })
                        Spacer()
                }
            })
            .sheet(isPresented: $dislayStatus.showBarCodeFlag) {
                BarcodeScannerView()
            }
        }
    }
    
    var totalPriceView: some View {
        Group{
            HStack {
                Text("定価の合計金額")
                Spacer()
                Text("\(dislayStatus.regular)"+"円")
            }.padding()
            HStack {
                Text("価値観の合計金額")
                Spacer()
                Text("\(dislayStatus.your)"+"円")
            }.padding()
        }
    }
}

struct HomeMoneyBooksView_Previews: PreviewProvider {
    static var previews: some View {
        HomeMoneyBooksView()
    }
}
