//
//  HistoryCellContent.swift
//  ProjectManager
//
//  Created by 이시원 on 2022/07/26.
//

import Foundation

struct HistoryCellContent {
    let title: String
    let createAt: String
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. d"
        return dateFormatter
    }()
    
    init(item: History) {
        switch item.changes {
        case .moved:
            title = "\(item.changes.rawValue) '\(item.title)' from \(item.beforeState?.rawValue ?? "") to \(item.afterState?.rawValue ?? "")"
        case .added:
            title = "\(item.changes.rawValue) '\(item.title)'"
        case .removed:
            title = "\(item.changes.rawValue) '\(item.title)' from \(item.beforeState?.rawValue ?? "")"
        }
        
        self.createAt = item.createAt.toString(dateFormatter)
    }
}
