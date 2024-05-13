//
//  DirectoryTreeFolderTableCellView.swift
//  SearchDirectory
//
//  Created by LiYing on 2024/5/6.
//

import Cocoa

class DirectoryTreeFolderTableCellView: NSTableCellView {

    @IBOutlet weak var labelFolderName: NSTextField!
    
    override var objectValue: Any? {
        didSet {
            if let value = objectValue as? DirectoryTreeModel {
                labelFolderName.stringValue = value.name
            }
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}
