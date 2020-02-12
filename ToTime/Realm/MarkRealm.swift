//
//  MarkRealm.swift
//  ToTime
//
//  Created by 김민국 on 2020/02/12.
//  Copyright © 2020 김민국. All rights reserved.
//

import Foundation
import RealmSwift

class MarkRealm {
    
    func getMarks() -> Results<MarkData>{
        let realm = try! Realm()
        return realm.objects(MarkData.self)
    }
    func getMark(id: String) -> MarkData{
        let realm = try! Realm()
        if let data = realm.object(ofType: MarkData.self, forPrimaryKey: id){
            return data
        }
        return MarkData(name: "", nameColor: "", bgColor: "", longitude: 0.0, latitude: 0.0, address: "")
    }
    
    func saveMark(obj: MarkData){
        let realm = try! Realm()
        do {
            try realm.write{
                realm.add(obj)
            }
        } catch {
            print("Realm Save Error")
        }
    }

    func deleteMark(id: String){
        let realm = try! Realm()

        if let data = realm.object(ofType: MarkData.self, forPrimaryKey: id){
            do {
                try realm.write{
                    realm.delete(data)
                }
            } catch {
                print("Realm Delete Error")
            }
        }
    }
}
