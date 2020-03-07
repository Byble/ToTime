//
//  HomeViewModel.swift
//  ToTime
//
//  Created by 김민국 on 2020/03/06.
//  Copyright © 2020 김민국. All rights reserved.
//

import Foundation
import Combine
import RealmSwift

class HomeViewModel: ObservableObject{
    @Published var marks: [MarkData] = [MarkData]()
    @Published var recentLoc: [String] = [String]()
    @Published var isReady: Bool = false
    @Published var isEdit: Bool = false
    @Published var isQuickView: Bool = false
    @Published var isNavigationBarHidden: Bool = true
    @Published var showAddMark: Bool = false
    @Published var locName = ""
    
    init(){
        fetchMarks()
        addObserver()
    }
}

extension HomeViewModel: HomeViewModelProtocol{
    func getMark(id: String) -> MarkData {
        return marks.filter{$0.uuid == id}.first ?? MarkData(name: "", longitude: 0.0, latitude: 0.0, address: "", iconName: "")
        
    }
    
    func addMark(obj: MarkData) {
        let realm = try! Realm()
        do {
            marks.append(obj)
            try realm.write{
                realm.add(obj)
            }
        } catch {
            print("Realm Save Error")
        }
    }
    
    func removeMark(at: IndexSet.Element) {
        let id = marks[at].uuid
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
        marks.remove(at: at)
    }
    
    func fetchMarks() {
        let realm = try! Realm()
        for data in realm.objects(MarkData.self){
            self.marks.append(data)
        }
        
        self.isReady = true
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyBoardWillShow(notification: Notification) {
        if !isEdit && !isQuickView{
            isEdit = true
        }
    }

    @objc func keyBoardDidHide(notification: Notification) {
        isEdit = false
    }
}
