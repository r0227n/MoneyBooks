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
    @Published var numberOfDisplay: [Int] = [0,0,0,0]
    
    let icons: [String] = ["bookmark.fill","book.fill","books.vertical.fill","paperclip.badge.ellipsis"]
    let colors: [Color] = [.red,.orange,.blue,.green]

    func updateNumber(){
        regular = 0
        your = 0
        numberOfDisplay = [0,0,0,0]
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
                               isActive: $openManagmentList,
                               label:{})
                
                Form {
                    Section(header: Text("合計")) {
                    GeometryReader{geometry in
                            HStack{
                                TotalGridItems(name: "定価", money: managementInformation.regular)
                                TotalGridItems(name: "コスパ", money: managementInformation.your)
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        }.frame(height: 100)
                    }
                    
                    Section {
                        Button(action: {
                            managementNumber = 0
                            openManagmentList.toggle()
                        }, label: {
                            HStack {
                                ZStack{
                                    Circle()
                                        .foregroundColor(managementInformation.colors[0])
                                    Image(systemName: managementInformation.icons[0])
                                        .foregroundColor(.white)
                                }
                                .position(x: 15.0, y: 15.0)
                                .frame(width: 30.0, height: 30.0)
                                Text(manualInput.managementStatus[0])
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("label"))
                                    .padding(5)
                                Spacer()
                                Text("\(managementInformation.numberOfDisplay[0])")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("label"))
                                    .padding()
                            }
                        })
                    }
                    Section(header: Text("マイリスト")){
                        ForEach(1..<4) { category in
                            Button(action: {
                                managementNumber = category
                                openManagmentList.toggle()
                            },label:{
                                HStack {
                                    ZStack{
                                        Circle()
                                            .foregroundColor(managementInformation.colors[category])
                                        Image(systemName: managementInformation.icons[category])
                                            .foregroundColor(.white)
                                    }
                                    .position(x: 15.0, y: 15.0)
                                    .frame(width: 30.0, height: 30.0)
                                    Text(manualInput.managementStatus[category])
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("label"))
                                        .padding(5)
                                    Spacer()
                                    Text("\(managementInformation.numberOfDisplay[category])")
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("label"))
                                        .padding()
                                }
                            })
                        }
                    }
                }
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
}

struct TotalGridItems: View {
    let name: String
    let money: Int
    init(name: String, money: Int){
        self.name = name
        self.money = money
    }
    var body: some View{
        GeometryReader{geometry in
            ZStack{
                RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Corner Radius@*/10.0/*@END_MENU_TOKEN@*/)
                VStack{
                    Text(name)
                    Text("\(money)"+"円")
                }.foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            }
            .foregroundColor(Color("backColor"))
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        
    }
    
}

struct HomeMoneyBooksView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeMoneyBooksView()
            HomeMoneyBooksView()
                .preferredColorScheme(.dark)
            HomeMoneyBooksView()
                .previewDevice("iPad Pro (12.9-inch) (4th generation)")
                
        }
    }
}
