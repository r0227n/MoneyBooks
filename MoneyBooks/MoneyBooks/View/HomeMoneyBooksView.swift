//
//  HomeMoneyBooksView.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2021/01/04.
//


import SwiftUI
import CoreData

class HomeItems : ObservableObject {
    @Published var numberOfDisplay: [Int] = [0,0,0,0]
    
    @Published var titles: [String] = ["新規追加"]
    @Published var memos: [String] = [""]
    @Published var pages: [Double] = [1000.0]
    @Published var reads: [Double] = [1.0]
    
    @Published var selection: Int = 0
    @Published var newTitle: String = ""
    @Published var closedSelector: Bool = false

    
    let icons: [String] = ["book.fill","book.closed.fill","books.vertical.fill","bag.fill"]
    let colors: [Color] = [.red,.orange,.blue,.green]
    

    func updateNumber(){
        titles = ["新規追加"]
        memos = [""]
        newTitle = ""
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
    
    var selectionTitls: some View {
        Group{
            DisclosureGroup("タイトル    "+manualInput.title, isExpanded: $homeItems.closedSelector) {
                Picker(selection: $homeItems.selection, label: Text("タイトル")) {
                    ForEach(0 ..< homeItems.titles.count) { num in
                        Text(homeItems.titles[num])
                    }
                }
                .onChange(of: homeItems.selection, perform: { select in
                    manualInput.title = homeItems.titles[homeItems.selection]
                    manualInput.memo = homeItems.memos[homeItems.selection]
                    manualInput.page = homeItems.pages[homeItems.selection]
                    manualInput.read = homeItems.reads[homeItems.selection]
                })
                .onAppear(perform:{
                    UIApplication.shared.endEditing()
                    homeItems.memos[homeItems.selection] = manualInput.memo
                })
                .pickerStyle(WheelPickerStyle())
                .frame(height: 140)
            }
            if(homeItems.selection+1 == homeItems.titles.count){
                TextField("新規タイトル名を入力してください",
                          text: $homeItems.newTitle,
                          onEditingChanged: { begin in
                    if(begin != false) {
                        homeItems.closedSelector = false
                    }else{
                        UIApplication.shared.endEditing()
                    }
                })
            }
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
                    Section(header: Text("読書中").font(.callout)) {
                        selectionTitls
                        MemoField(read: $manualInput.read, total: $manualInput.page, memo: $manualInput.memo)
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
                ToolbarItem(placement: .automatic){
                    if(homeItems.selection+1 == homeItems.titles.count){
                        Button(action: {
                            UIApplication.shared.endEditing()
                            addItem()
                        }, label: {
                            Text("追加")
                                .font(.largeTitle)
                        })
                    }else{
                        Button(action: {
                            UIApplication.shared.endEditing()
                            updateItem()
                        }, label: {
                            Text("更新")
                                .font(.largeTitle)
                        })
                    }
                }
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
                homeItems.pages.insert($0.page, at: 0)
                homeItems.reads.insert($0.read, at: 0)
            }
            homeItems.numberOfDisplay[Int($0.save)] += 1
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Books(context: viewContext)
            newItem.id = UUID().uuidString
            newItem.webImg = ""
            newItem.img = UIImage(systemName: "nosign")!.jpegData(compressionQuality: 0.80)
            newItem.title = homeItems.newTitle
            newItem.author =  "未入力"
            newItem.regular = Int16(0)
            newItem.buy = Date()
            newItem.save = Int16(0)
            newItem.memo = manualInput.memo
            newItem.impressions =  ""
            newItem.favorite = Int16(0)
            newItem.page = manualInput.page
            newItem.read = manualInput.read
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        resetNumber()
    }
    
    private func updateItem() {
        let fetchRequest: NSFetchRequest<Books> = Books.fetchRequest()
        fetchRequest.predicate = NSPredicate.init(format: "title=%@", manualInput.title)
        do {
            let editItem = try self.viewContext.fetch(fetchRequest).first
            editItem?.memo = manualInput.memo
            editItem?.read = manualInput.read
            try self.viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        resetNumber()
    }
}


struct MemoField: View {
    @Binding var read: Double
    @Binding var total: Double
    @Binding var memo: String
    var body: some View {
        VStack {
            Group {
                Slider(value: $read, in: 0...total, step: 1)
                Stepper(value: $read, in: 0...total) {
                    HStack {
                        Text("ページ数")
                        Spacer()
                        Text("\(Int(read))" + "  /  " + "\(Int(total))"+"ページ")
                        Spacer()
                    }
                }
            }.frame(height: 30)
            TextEditor(text: $memo)
                .frame(height: 140)
        }
    }
}
