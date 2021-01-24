//
//  HomeMoneyBooksView.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2021/01/04.
//


import SwiftUI
import CoreData

class HomeItems : ObservableObject {
    @Published var regular:Int = 0
    @Published var numberOfDisplay: [Int] = [0,0,0,0]
    
    @Published var titles: [String] = ["新規追加"]
    @Published var memos: [String] = [""]
    @Published var selection: Int = 0
    @Published var memo: String = ""
    @Published var newTitle: String = ""
    @Published var closedSelector: Bool = false

    
    let icons: [String] = ["book.fill","book.closed.fill","books.vertical.fill","bag.fill"]
    let colors: [Color] = [.red,.orange,.blue,.green]

    func updateNumber(){
        titles = ["新規追加"]
        memos = [""]
        regular = 0
        numberOfDisplay = [0,0,0,0]
    }
}


struct HomeMoneyBooksView: View {
    @FetchRequest(
        sortDescriptors: [ NSSortDescriptor(keyPath: \Books.id, ascending: true) ],
        animation: .default)
    var items: FetchedResults<Books>

    @StateObject var homeItems = HomeItems()
    @StateObject var manualInput = ManualInput()
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var openBarcodeScannerView:Bool = false
    @State var managementNumber:Int = 1
    @State var openManagmentList:Bool = false
    
    struct BookShelfTitle: View {
        let items: Int
        var body: some View{
            HStack(spacing: 10) {
                Text("本棚")
                Text("\(items)"+" 冊")
            }
            .font(.callout)
        }
    }
    
    var bookshelf: some View {
        ForEach(0..<4) { category in
            Button(action: {
                managementNumber = category
                openManagmentList.toggle()
            },label:{
                HStack {
                    ZStack{
                        Circle()
                            .foregroundColor(homeItems.colors[category])
                        Image(systemName: homeItems.icons[category])
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
                    Text("\(homeItems.numberOfDisplay[category])")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("label"))
                        .padding()
                }
            })
        }
    }
    
    var body: some View {
        NavigationView {
            VStack{ // VStack(HStack)でまとめないと何故か表示されない
                NavigationLink(destination: ListManagementView(numberOfBooks: $managementNumber,
                                                               listViewTitle: $manualInput.managementStatus[managementNumber]),
                               isActive: $openManagmentList,
                               label:{})
                List {
                    Section(header: Text("読書中")) {
                        DisclosureGroup(homeItems.titles[homeItems.selection], isExpanded: $homeItems.closedSelector) {
                            Picker(selection: $homeItems.selection, label: Text("タイトル")) {
                                ForEach(0 ..< homeItems.titles.count) { num in
                                    Text(homeItems.titles[num])
                                }
                            }
                            .onChange(of: homeItems.selection, perform: { select in
                                homeItems.memo = homeItems.memos[homeItems.selection]
                            })
                            .onAppear(perform:{
                                UIApplication.shared.endEditing()
                                homeItems.memos[homeItems.selection] = homeItems.memo
                            })
                            .pickerStyle(WheelPickerStyle())
                            .frame(height: 100)
                        }
                        if(homeItems.selection+1 == homeItems.titles.count){
                            GeometryReader{ geometry in
                            HStack {
                                TextField("タイトルを入力してください", text: $homeItems.newTitle)
                                Spacer()
                                Button(action: {
                                    
                                }, label: {
                                    ZStack{
                                        Capsule()
                                        Text("新規追加")
                                            .foregroundColor(.white)
                                    }
                                })
                                .foregroundColor(.red)
                                .frame(width: geometry.size.width / 4, height: geometry.size.height)
                            }
                                
                           }
                        }
                        TextEditor(text: $homeItems.memo)
                            .frame(height: 100)
                            .onTapGesture {
                                UIApplication.shared.endEditing()
                                homeItems.closedSelector = false
                            }
                    }
                    Section(header:BookShelfTitle(items: homeItems.numberOfDisplay.reduce(0) { $0 + $1 })){
                        bookshelf
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
    
    private func resetNumber(){
        homeItems.updateNumber()
        //起動時、カテゴリー別の管理数をカウントする
        items.forEach {
            if($0.save == 0){
                homeItems.titles.insert($0.title ?? "", at: 0)
                homeItems.memos.insert($0.memo ?? "", at: 0)
            }
            homeItems.regular += Int($0.regular)
            homeItems.numberOfDisplay[Int($0.save)] += 1
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = MoneyBooks.Books(context: viewContext)
            let pickedImage = UIImage(systemName: "nosign")!.jpegData(compressionQuality: 0.80)
            newItem.id = UUID()
            newItem.webImg = ""
            newItem.img = pickedImage!
            newItem.title = homeItems.newTitle
            newItem.author =  "未入力"
            newItem.regular = Int16(0)
            newItem.buy = Date()
            newItem.save = Int16(0)
            newItem.memo = homeItems.memo
            newItem.impressions =  ""
            newItem.favorite = Int16(0)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}





struct HomeMoneyBooksView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeMoneyBooksView()
//            HomeMoneyBooksView()
//                .preferredColorScheme(.dark)
//            MyReading(title: .constant("test"), memo: .constant("memo"))
//                .previewLayout(PreviewLayout.fixed(width: 300, height: 100))
//                .padding()
//                .previewDisplayName("Default preview")
        }
    }
}
