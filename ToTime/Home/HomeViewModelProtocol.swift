//
//  HomeViewModelProtocol.swift
//  ToTime
//
//  Created by 김민국 on 2020/03/06.
//  Copyright © 2020 김민국. All rights reserved.
//

import Foundation
import Combine

protocol HomeViewModelProtocol {
    var marks: [MarkData] { get }
    func fetchMarks()
    func getMark(id: String) -> MarkData
    func addMark(obj: MarkData)
    func removeMark(at: IndexSet.Element)
}
