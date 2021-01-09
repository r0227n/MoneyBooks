//
//  TypeBookDataView.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2021/01/05.
//

import SwiftUI

enum Signal: Int {
    case one = 1
    case yellow = 2
    case red = 3
}

struct TypeBookDataView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var setImage:UIImage?
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var displayStatus: DisplayStatus
    
    @Binding var title: String
    @Binding var author: String
    @Binding var dateOfPurchase: Date
    @Binding var edit: Bool
    @Binding var regularPrice: String
    @Binding var yourValue: String
    @Binding var memo: String
    @Binding var impressions: String
    @Binding var favorite: Int
    @Binding var unfavorite: Int
    
    @State private var stateOfControl: Int = 1
    
    var body: some View {
        Form {
            Section(header: Text("表紙")){
                HStack {
                    Spacer()
                    LocalImageView(inputImage: $setImage)
                        .frame(width: 200, height: 200, alignment: .center)
                    Spacer()
                }
                TextField("本のタイトルを入力してください", text: $title)
                TextField("作者を入力してください", text: $author)
                
                TextField("定価を入力してください", text: $regularPrice,
                          onEditingChanged: { begin in
                            regularPrice = checkerYen(begin: begin, typeMoney: regularPrice)
                            
                          })
                    .keyboardType(.numbersAndPunctuation)
                
                DatePicker("購入日", selection: $dateOfPurchase, displayedComponents: .date)
                
                Picker(selection: $stateOfControl, label: Text("管理先を指定してください")) {
                    ForEach(0 ..< displayStatus.managementStatus.count) { num in
                        Text(self.displayStatus.managementStatus[num])
                    }
                }
            }
            Section(header: Text("メモ")){
                TextEditor(text: $memo)
            }
            if(stateOfControl == 0){
                Group {
                    Section(header: Text("感想")){
                        TextEditor(text: $impressions)
                    }
                    Section(header: Text("あなたにとってこの本は？")){
                        HStack(spacing: 10) {
                            ForEach(0..<favorite, id:\.self){ yellow in
                                Image(systemName: "star.fill")
                                    .onTapGesture(perform: {
                                        favorite = yellow + 1
                                        unfavorite = 4 - yellow
                                    })
                                    .foregroundColor(.yellow)
                                    .padding()
                            }
                            ForEach(0..<unfavorite, id: \.self){ gray in
                                Image(systemName: "star.fill")
                                    .onTapGesture(perform: {
                                        favorite += (gray + 1)
                                        unfavorite -= (gray + 1)
                                    })
                                    .padding()
                                    .foregroundColor(.gray)
                            }
                        }
                        TextField("どれぐらいの価値ですか？", text: $yourValue,
                                  onEditingChanged: { begin in
                                    yourValue = checkerYen(begin: begin, typeMoney: yourValue)
                                  })
                            .keyboardType(.numbersAndPunctuation)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text("手入力画面"))
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing){ // ナビゲーションバー左
                Button(action: {
                    addItem()
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("追加")
                })
            }
            ToolbarItem(placement: .navigationBarLeading){
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.blue)
                        Text("戻る")
                    }
                })
            }
        })
        .gesture(
            DragGesture(minimumDistance: 0.5, coordinateSpace: .local)
                .onEnded({ value in // end time
                    if value.startLocation.x < CGFloat(100.0){  // スワイプの開始地点が左端
                        self.presentationMode.wrappedValue.dismiss()
                    }
                })
        )
        .onAppear(perform: {
            if(displayStatus.managementNumber > 2){
                stateOfControl = 1
                displayStatus.managementNumber = 1
            }else{
                stateOfControl = displayStatus.managementNumber
            }
        })
    }
    
    private func addItem() {
        withAnimation {
            let newItem = MoneyBooks.Books(context: viewContext)
            var pickedImage = setImage?.jpegData(compressionQuality: 0.80)  // UIImage -> Data
            
            if pickedImage == nil { // 画像が選択されていない場合
                pickedImage = UIImage(imageLiteralResourceName: "sea").jpegData(compressionQuality: 0.80)
            }
            newItem.img = pickedImage!
            newItem.title = title
            newItem.author =  author
            newItem.regularPrice = dataSetMoney(setMoney: regularPrice)
            newItem.dateOfPurchase = dateOfPurchase
            newItem.stateOfControl = Int16(stateOfControl)
            newItem.memo = memo
            newItem.impressions =  impressions
            newItem.favorite = Int16(favorite)
            newItem.yourValue = dataSetMoney(setMoney: yourValue)
            do {
                try viewContext.save()
                switch stateOfControl {
                case 0:
                    displayStatus.read += 1
                case 1:
                    displayStatus.buy += 1
                case 2:
                    displayStatus.want += 1
                default:
                    break
                }
                displayStatus.closedSearchView = true
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func checkerYen(begin:Bool, typeMoney:String) -> String {
        var indexOfYen = typeMoney
        if(begin && (indexOfYen.contains("円"))) {
            indexOfYen = String(indexOfYen.dropLast(1))
        } else if(indexOfYen.count > 0){
            indexOfYen += "円"
        }
        return indexOfYen
    }
    
    
    func dataSetMoney(setMoney: String) -> Int16 {
        var recordOfMoney = setMoney
        if(recordOfMoney.contains("円")){
            recordOfMoney = String(recordOfMoney.dropLast(1))
            return Int16(recordOfMoney)!
        }else{
            return 0
        }
    }
}

//struct TypeBookDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        TypeBookDataView()
//    }
//}
