//
//  DirectoryTreeModel.swift
//  SearchDirectory
//
//  Created by LiYing on 2024/5/4.
//

import Cocoa

class DirectoryTreeModel: NSObject {
    var name: String = ""
    var icon: NSImage?
    var fullPath: String = ""
    var createDate: Date?
    var size: Int?
    var parent: DirectoryTreeModel?
    var children: [DirectoryTreeModel]?
    var isDirectory: Bool = false
    var isHidden: Bool = false
    var isPackage: Bool = false
    
    override init() {
        super.init()
    }
    
    init(_ resource: URLResourceValues?) {
        let name = resource?.name ?? "Unknown"
        let icon = resource?.effectiveIcon as? NSImage
        let fullPath = resource?.path
        let date = resource?.creationDate ?? Date()
        let size = resource?.fileSize ?? 0
        let isDirectory = resource?.isDirectory ?? false
        let isHidden = resource?.isHidden ?? false
        let isPackage = resource?.isPackage ?? false
        
        self.name = name
        self.icon = icon
        self.fullPath = fullPath ?? ""
        self.createDate = date
        self.size = size
        self.parent = nil
        self.children = []
        self.isDirectory = isDirectory
        self.isHidden = isHidden
        self.isPackage = isPackage
    }
}
