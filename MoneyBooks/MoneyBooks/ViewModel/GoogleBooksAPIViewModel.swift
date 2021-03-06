//
//  GBooksDataViewModel.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2020/12/11.
//

import SwiftyJSON
 
class GoogleBooksAPIViewModel : ObservableObject {
    
    @Published var data = [Book]()

    func getData(request: String) -> Void{
        let url = "https://www.googleapis.com/books/v1/volumes?q=" + request
        let session = URLSession(configuration: .default)
        session.dataTask(with: URL(string: url)!) { (data, _, err) in
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            
            let json = try! JSON(data: data!)
            guard let items = json["items"].array else {
                print("error")
                return
            }
            for i in items{
                let id = i["id"].stringValue
                
                let title = i["volumeInfo"]["title"].stringValue
                
                var authors = i["volumeInfo"]["authors"].array
                if authors == nil {
                    authors = ["データなし"]
                }

                var pageCount = i["volumeInfo"]["pageCount"].stringValue
                pageCount = pageCount.count == 0 ? "" : pageCount + "ページ"
                
                var author = ""
                
                for j in authors!{
                  
                    author += "\(j.stringValue)"
                }
                
                let description = i["volumeInfo"]["description"].stringValue
                
                let imurl = i["volumeInfo"]["imageLinks"]["thumbnail"].stringValue
                
                let url1 = i["volumeInfo"]["previewLink"].stringValue
                
                DispatchQueue.main.async {
                    self.data.append(Book(id: id, title: title, authors: author, pageCount: pageCount, desc: description, imgUrl: imurl, url: url1))
                }
            }
        }.resume()
    }
}

struct Book : Identifiable {
    var id : String
    var title : String
    var authors : String
    var pageCount: String
    var desc : String
    var imgUrl : String
    var url : String
}
