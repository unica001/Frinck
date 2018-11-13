//
//  DBManager.swift
//  Frinck
//
//  Created by vineet patidar on 12/06/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import SQLite3


class DBManager: NSObject {
    
    class var sharedInstance: DBManager {
        struct Static {
            static let instance = DBManager()
        }
        return Static.instance
    }
}

    var db: OpaquePointer? = nil


    // get direcoty path
    func getPath(_ fileName:String) -> String{
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileUrl = documentURL.appendingPathComponent(fileName)
        
        return fileUrl.path
    }
    
    func copyFile(_ fileName : String) {
        
        let dbPath = getPath(fileName)
        let fileManager = FileManager.default
        
        // check if  DB already exist  on path
        if !fileManager.fileExists(atPath: dbPath){
            let documentUrl = Bundle.main.resourceURL
            let fromPath = documentUrl?.appendingPathComponent(fileName)
            do {
                try  fileManager.copyItem(atPath: (fromPath?.path)!, toPath: dbPath)
            }
            catch  let error as NSError{
                print(error.localizedDescription)
            }
        }
        openDatabase()
    }
    
    func openDatabase() {
        let dbPath = getPath("Frinck.sqlite")
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("Successfully opened connection to database at \(dbPath)")
            
            let querytring = "CREATE TABLE IF NOT EXISTS StoryTable (id INTEGER PRIMARY KEY  NOT NULL UNIQUE , image BLOB, customerId INTEGER, brandId INTEGER, storeId INTEGER, mediaType TEXT, description TEXT)"
            var stmt: OpaquePointer?
             if sqlite3_prepare_v2(db, querytring, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
            }
        } else {
            print("Unable to open database.")
        }
    }


    // Story table
    func insertDataInStoryTable(_ imgData : NSData,_ customerId : String,_ brandId : String,_ storeId : String,_ description : String, media: String) -> Bool {
        
        var stmt: OpaquePointer?
        
        var isInsert : Bool = true
        
        let queryString = "INSERT INTO StoryTable (image, customerId,brandId,storeId,mediaType,description) VALUES (?,?,?,?,?,?)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
        }
        
        if sqlite3_bind_blob(stmt, 1, imgData.bytes, Int32(imgData.length), nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
        }
        
        if sqlite3_bind_int(stmt, 2, Int32(customerId)!) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
        }
        
        if sqlite3_bind_int(stmt, 3, Int32(brandId)!) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
        }
        if sqlite3_bind_int(stmt, 4, Int32(storeId)!) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
        }
        if sqlite3_bind_text(stmt, 5, media, -1, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
        }
        if sqlite3_bind_text(stmt, 6,description ,-1, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
        }
       
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            isInsert = false
        }
        return isInsert
    }
    
     func getStoryData() -> [[String : Any]] {
        
        var  postStoryArray = [[String : Any]]()
        let queryString = "SELECT * FROM StoryTable"
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            
            var dict = [String : Any]()
            
//            let Id = sqlite3_column_int(stmt, 0)
            let length = sqlite3_column_bytes(stmt, 1);
            
            let data = NSData(bytes: sqlite3_column_blob(stmt, 1), length:Int(length))
            let customerId = sqlite3_column_int(stmt, 2)
            let brandId = sqlite3_column_int(stmt, 3)
            let storeId = sqlite3_column_int(stmt, 4)
            let media = String(cString: sqlite3_column_text(stmt, 5))
            let description = String(cString: sqlite3_column_text(stmt, 6))
            if media == "image" {
                let image : UIImage = UIImage(data: data as Data)!
                dict["image"] = image
            } else {
                dict["data"] = data as Data
            }
//            dict["id"] = Id
               dict["customerId"] = String(customerId)
               dict["brandId"] = String(brandId)
               dict["storeId"] = String(storeId)
               dict["description"] = description
               dict["mediaType"] = media
            print(dict)
            postStoryArray.append(dict)
        }
        print(postStoryArray)
        return postStoryArray
    }


    func deleteStoryDataFromDatabase(){

        let queryString = "DELETE FROM StoryTable"
        print(queryString)
        var stmt:OpaquePointer?
        if sqlite3_prepare(db, queryString, -1,  &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(stmt)
    
    }


// MARK : Payment Table

func insertPaymentRecordInDB(_ customer_id : NSInteger,_ payment_id : String,_ point_used : NSInteger,_ price : NSInteger) -> Bool {
    
    var stmt: OpaquePointer?
    
    
    let queryString = "INSERT INTO paymentTable (customer_id, payment_id,point_used,price) VALUES (?,?,?,?)"
    
    var isInsert : Bool = true

    if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        print("error preparing insert: \(errmsg)")
    }
    if sqlite3_bind_int(stmt, 1, Int32(customer_id)) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        print("failure binding name: \(errmsg)")
    }
    
    if sqlite3_bind_text(stmt, 2,payment_id,-1, nil) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        print("failure binding name: \(errmsg)")
    }

    
    if sqlite3_bind_int(stmt, 3, Int32(point_used)) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        print("failure binding name: \(errmsg)")
    }
    
    if sqlite3_bind_int(stmt, 4, Int32(price)) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        print("failure binding name: \(errmsg)")
    }
    
    if sqlite3_step(stmt) != SQLITE_DONE {
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        print("failure inserting hero: \(errmsg)")
        isInsert = false
    }
    sqlite3_finalize(stmt)

    return isInsert
}

func getPaymentRecordFromDB() -> [[String : Any]]{
    
    var  paymentArray = [[String : Any]]()
    let queryString = "SELECT * FROM paymentTable"
    var stmt:OpaquePointer?
    
    if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        print("error preparing insert: \(errmsg)")
    }
    
    while(sqlite3_step(stmt) == SQLITE_ROW){
        
        var dict = [String : Any]()
        
        let customer_id = sqlite3_column_int(stmt, 1)
        let payment_id = String(cString: sqlite3_column_text(stmt, 2))

        let point_used = sqlite3_column_int(stmt, 3)
        let price = sqlite3_column_int(stmt, 4)

        
        dict["customer_id"] = String(customer_id)
        dict["payment_id"] = payment_id
        dict["point_used"] = String(point_used)
        dict["price"] = String(price)
        paymentArray.append(dict)
    }
    
    sqlite3_finalize(stmt)

    print(paymentArray)
    return paymentArray
}


func deletePaymentRecordFromDB(customerId : String, storyId : String) -> Bool{
    var isDelete : Bool = true
    let queryString = "DELETE from paymentTable where customer_id = \(customerId)"
    var stmt:OpaquePointer?
    if sqlite3_prepare(db, queryString, -1,  &stmt, nil) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        print("error preparing insert: \(errmsg)")
        isDelete = false
    }
    return isDelete
}
