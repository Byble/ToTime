//
//  ResourceManager.swift
//  ToTime
//
//  Created by 김민국 on 2020/03/07.
//  Copyright © 2020 김민국. All rights reserved.
//

import Foundation
import SwiftUI
class DataManager {
    var names: [String] = []
    
    init(){
        fetchMarkIcons()
    }
    
    func fetchMarkIcons(){
        
        if let f = Bundle.main.url(forResource: "MarkIcon", withExtension: nil) {
            let fm = FileManager()
            let datas =  (try? fm.contentsOfDirectory(at: f, includingPropertiesForKeys: nil, options: [])) ?? []
            for data in datas{
                names.append(data.absoluteString)
            }
        }
    }        
}

func loadIcon(fileName: String) -> UIImage? {
    do {
        if let fileURL = URL(string: fileName){            
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        }
    } catch {
        print("Error loading image : \(error)")
    }
    return nil
}

func getFileName(fullURL: String) -> String{
    let url = URL(string: fullURL)
    return url?.lastPathComponent.components(separatedBy: ".").first ?? ""
}
