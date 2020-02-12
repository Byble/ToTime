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
    
    var marks: [MarkData] = []
    init(){
        let realm = try! Realm()
        for data in realm.objects(MarkData.self){
            marks.append(data)
        }
    }
    
    func saveMark(obj: Object){
        let realm = try! Realm()
        do {
            try realm.write{
                realm.add(obj)
            }
        } catch {
            print("Realm Save Error")
        }
    }

    func deleteMark(obj: Object){
        let realm = try! Realm()
        do {
            try realm.write{
                realm.delete(obj)
            }
        } catch {
            print("Realm Delete Error")
        }
    }
}
