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
    
    let icons: [String] = ["book.fill","book.closed.fill","books.vertical.fill","bag.fill"]
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
                    Section(header: Text("合計金額").font(.callout)) {
                        GeometryReader{ geometry in
                            HStack {
                                GridItems(text: "定価",
                                          money: managementInformation.regular,
                                          width: geometry.size.width/2,
                                      height: geometry.size.height)
                                GridItems(text: "コスパ",
                                          money: managementInformation.your,
                                          width: geometry.size.width/2,
                                          height: geometry.size.height)
                            }
                            .foregroundColor(Color("gridItems"))
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
                    Section(header:
                                HStack(spacing: 10) {
                                    Text("本棚")
                                    Text("\(managementInformation.numberOfDisplay.reduce(0) { $0 + $1 })"+" 冊")
                                }
                                .font(.callout)
                    ){
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
}

struct GridItems: View {
    let text: String
    let money: Int
    let width: CGFloat
    let height: CGFloat
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Corner Radius@*/10.0/*@END_MENU_TOKEN@*/)
                .foregroundColor(Color("gridItems"))
            VStack(alignment: .leading) {
                Text(text)
                    .font(.subheadline)
                    .frame(width: width, height: 10, alignment: .leading)
                    .offset(x: 10, y: 0)
                HStack(alignment: .center) {
                    Spacer()
                    Group{
                        Text("\(money)")
                            .font(.headline)
                            .padding(5)
                        Text("円")
                    }.padding(5)
                }
            }
            .foregroundColor(Color("label"))
        }
        .frame(width: width, height: height)
    }
}

struct TotalItems: View {
    let category: [String] = ["定価","コスパ","登録数"]
    let money: [Int] = [1000,20000,10]
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                ForEach(0..<2){ item in
                    HStack {
                        Text(category[item])
                            .offset(x: 10)
                        Spacer()
                        Text("\(money[item])")
                            .padding(10)
                        Text("円")
                    }
                    Divider()
                }
                HStack{
                    Text(category[2])
                        .offset(x: 10)
                    Spacer()
                    Text("\(money[2])")
                        .padding(10)
                    Text("冊")
                }
            }
        }
    }
}

struct HomeMoneyBooksView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeMoneyBooksView()
            HomeMoneyBooksView()
                .preferredColorScheme(.dark)
                
        }
    }
}
