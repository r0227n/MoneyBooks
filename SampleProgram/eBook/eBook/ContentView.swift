//
//  ContentView.swift
//  eBook
//
//  Created by Kavsoft on 16/03/20.
//  Copyright © 2020 Kavsoft. All rights reserved.
//

import SwiftUI
import SwiftyJSON
import SDWebImageSwiftUI // ネット上の画像を取得
import WebKit

struct ContentView: View {
    var body: some View {
        
        NavigationView{
            
            Home()
            .navigationBarTitle("Books")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home : View {
    
    @ObservedObject var Books = getData()
    @State var show = false
    @State var url = ""
    
    var body : some View{
        
        
        List(Books.data){i in
            
            HStack{
                if i.imurl != ""{
                  WebImage(url: URL(string: i.imurl)!).resizable().frame(width: 120, height: 170).cornerRadius(10) // SDWebImageの関数
                }
                else{
                    
                    Image("books").resizable().frame(width: 120, height: 170).cornerRadius(10)
                }

                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text(i.title).fontWeight(.bold)
                    
                    Text(i.authors)
                    
                    Text(i.desc).font(.caption).lineLimit(4).multilineTextAlignment(.leading)
                }
            }
            .onTapGesture {
                print(i.imurl)
                self.url = i.url
                self.show.toggle()
            }
            
        }.sheet(isPresented: self.$show) {
            
            WebView(url: self.url)
        }
    }
}

class getData : ObservableObject{
    
    @Published var data = [Book]()
    
    init() {
        
        // any search query....
        //spaces must be replaced by +...
        
        let url = "https://www.googleapis.com/books/v1/volumes?q=9784061538238"
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: URL(string: url)!) { (data, _, err) in
            
            if err != nil{
                
                print((err?.localizedDescription)!)
                return
            }
            
            let json = try! JSON(data: data!)
            let items = json["items"].array!
            
            for i in items{
                
                let id = i["id"].stringValue
                
                let title = i["volumeInfo"]["title"].stringValue
                
                let authors = i["volumeInfo"]["authors"].array!
                
                var author = ""
                
                for j in authors{
                    
                    author += "\(j.stringValue)"
                }
                
                let description = i["volumeInfo"]["description"].stringValue
                
                let imurl = i["volumeInfo"]["imageLinks"]["thumbnail"].stringValue
                
                let url1 = i["volumeInfo"]["previewLink"].stringValue
                print(i["saleInfo"]["listPrice"]["amount"])  // book price
                DispatchQueue.main.async {
                    
                    self.data.append(Book(id: id, title: title, authors: author, desc: description, imurl: imurl, url: url1))
                }
            }
            
        }.resume()
    }
}

struct Book : Identifiable {
    
    var id : String
    var title : String
    var authors : String
    var desc : String
    var imurl : String
    var url : String
}


struct WebView : UIViewRepresentable {
    
    var url : String
    
    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        
        let view = WKWebView()
        print("test",url)
        //view.load(URLRequest(url: URL(string: url)!))
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
        
        
    }
}
