//
//  GBooksDataViewModel.swift
//  MoneyBooks
//
//  Created by RyoNishimura on 2020/12/11.
//

import SwiftyJSON
 
final class GoogleBooksAPIViewModel : ObservableObject {
    
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
            let items = json["items"].array!
            var flag:Bool = false
            for i in items{
                if(flag != true){
                    let id = i["id"].stringValue
                    
                    let title = i["volumeInfo"]["title"].stringValue
                    
                    var authors = i["volumeInfo"]["authors"].array
                    if authors == nil {
                        authors = ["データなし"]
                    }

                    let isbn = i["volumeInfo"]["industryIdentifiers"].array!
                    
                    var author = ""
                    
                    for j in authors!{
                      
                        author += "\(j.stringValue)"
                    }
                    
                    let description = i["volumeInfo"]["description"].stringValue
                    
                    let imurl = i["volumeInfo"]["imageLinks"]["thumbnail"].stringValue
                    
                    let url1 = i["volumeInfo"]["previewLink"].stringValue
                    
                    for test in isbn {
                        if(test["identifier"].string! == request){
                            DispatchQueue.main.async {
                                self.data.append(Book(id: id, title: title, authors: author, desc: description, imgUrl: imurl, url: url1))
                            }
                            flag.toggle()
                            break
                        }
                    }
                }
                else{
                    break
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
    var imgUrl : String
    var url : String
}
