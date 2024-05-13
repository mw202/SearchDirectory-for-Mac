//
//  MainViewController.swift
//  SearchDirectory
//
//  Created by LiYing on 2024/5/4.
//

import Cocoa

class MainViewController: NSViewController {

    @IBOutlet weak var textFieldPath: NSTextField!
    @IBOutlet weak var buttonRefresh: NSButton!
    @IBOutlet weak var outlineViewDirectory: NSOutlineView!
    
    @IBOutlet weak var tableViewFile: NSTableView!
    @IBOutlet var menuFile: NSMenu!
    @IBOutlet weak var menuItemOpenFile: NSMenuItem!
    @IBOutlet weak var menuItemOpenFolder: NSMenuItem!
    @IBOutlet weak var labelFileCount: NSTextField!
    
    private var items: [DirectoryTreeModel]?
    private var files: [DirectoryTreeModel]? {
        willSet {
            labelFileCount.stringValue = "\(newValue?.count ?? 0) 个文件"
        }
    }
    private var sortDescriptor: NSSortDescriptor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        items = []
        files = []
        
        setupUI()
        
//        let acc = url?.startAccessingSecurityScopedResource()
        
        enumerateDirectory(URL(fileURLWithPath: textFieldPath.stringValue, isDirectory: true), &self.items)
        
        outlineViewDirectory.reloadData()
        tableViewFile.reloadData()
    }
    
    // MARK: -
    
    func setupUI() {
        tableViewFile.menu = menuFile
        tableViewFile.sizeToFit()
        
        textFieldPath.stringValue = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("Developer/CoreSimulator/Devices").path ?? ""
        #if DEBUG
        textFieldPath.stringValue = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("Developer/Xcode/Archives").path ?? ""
        #endif
        
//        // 双击
//        tableViewFile.target = self
//        tableViewFile.doubleAction = #selector(tableViewDoubleClick(_:))
        
        // 排序
        let sortName = NSSortDescriptor(key: "name", ascending: true)
        let sortDate = NSSortDescriptor(key: "createDate", ascending: true)
        let sortSize = NSSortDescriptor(key: "size", ascending: true)
        tableViewFile.tableColumns.safeObject(index: 0)?.sortDescriptorPrototype = sortName
        tableViewFile.tableColumns.safeObject(index: 1)?.sortDescriptorPrototype = sortDate
        tableViewFile.tableColumns.safeObject(index: 2)?.sortDescriptorPrototype = sortSize
    }
    
    func enumerateDirectory(_ url: URL, _ items: inout [DirectoryTreeModel]?) {
        let fileManager = FileManager.default
        
        let keys: [URLResourceKey] = [.creationDateKey, .isHiddenKey, .isDirectoryKey, .parentDirectoryURLKey, .fileSizeKey, .nameKey, .localizedNameKey, .isPackageKey, .customIconKey, .effectiveIconKey, .pathKey, .customIconKey]
        
        /*
        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: keys, options: [.skipsPackageDescendants], errorHandler: nil) {
            for case let u as URL in enumerator {
                let resource = try? u.resourceValues(forKeys: Set(keys))
                let isDir = resource?.isDirectory ?? false
                let date = resource?.creationDate ?? Date()
                let size = resource?.fileSize ?? 0
                let name = resource?.name ?? "Unknown"
                let isPackage = resource?.isPackage ?? false
                print("\(enumerator.level):\(u.path)--\(isDir)-\(isPackage)--\(size)")
            }
            
            while let u = enumerator.nextObject() {
                
                let resource = try? (u as? URL)?.resourceValues(forKeys: Set(keys))
                let level = enumerator.level
                let attributes = try? fileManager.attributesOfItem(atPath: (u as! URL).path)
                let type = attributes?[.type] as? FileAttributeType
                let date = attributes?[.creationDate]
                let size = attributes?[.size]

                print("\((u as! URL).path):--\(type!.rawValue)--\(size!)")
                //let name = attributes?[.name]
                if type == FileAttributeType.typeDirectory {
                    // 文件夹
                }
            }
        }
        */
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            for content in contents {
                let resource = try? content.resourceValues(forKeys: Set(keys))
                let item = DirectoryTreeModel(resource)
                items?.append(item)
                if item.isDirectory {
                    enumerateDirectory(content, &item.children)
                }
            }
        } catch {
            //
        }
    }
    
    func sortedFile(_ items: [DirectoryTreeModel]?) -> [DirectoryTreeModel]? { 
        // sortedArray(using sortDescriptors: [NSSortDescriptor]) 闪退
        return items?.sorted { (c1, c2) -> Bool in
            var b = true
            if let sd = self.sortDescriptor {
                var b1 = true
                if sd.key == "name" {
                    if sd.ascending {
                        b1 = (c1.name > c2.name)
                    } else {
                        b1 = (c1.name < c2.name)
                    }
                    b = b && b1
                }
                if sd.key == "createDate" {
                    if sd.ascending {
                        b1 = (c1.createDate ?? Date() > c2.createDate ?? Date())
                    } else {
                        b1 = (c1.createDate ?? Date() < c2.createDate ?? Date())
                    }
                    b = b && b1
                }
                if sd.key == "size" {
                    if sd.ascending {
                        b1 = (c1.size ?? 0 > c2.size ?? 0)
                    } else {
                        b1 = (c1.size ?? 0 < c2.size ?? 0)
                    }
                    b = b && b1
                }
            }
            return b
        }
    }
    
    func openUrl(_ index: Int, isDirectory: Bool = false) {
        guard index >= 0 else {
            return
        }
        
        if let item = files?.safeObject(index: index) {
            var url = URL(fileURLWithPath: item.fullPath)
            if isDirectory {
                url = url.deletingLastPathComponent()
            }
            
            NSWorkspace.shared.open(url)
        }
    }
    
    // MARK: - Click
    
    @IBAction func folderDoubleClick(_ sender: NSOutlineView) {
    }
    
    @IBAction func fileDoubleClick(_ sender: NSTableView) {
        let index = tableViewFile.selectedRow
        openUrl(index, isDirectory: false)
    }
    
    @IBAction func clickRefresh(_ sender: Any) {
        items?.removeAll()
        files?.removeAll()
        
        enumerateDirectory(URL(fileURLWithPath: textFieldPath.stringValue), &items)
        
        outlineViewDirectory.reloadData()
        tableViewFile.reloadData()
    }
    
    @IBAction func clickOpenFile(_ sender: Any) {
        let index = tableViewFile.clickedRow
        openUrl(index, isDirectory: false)
    }
    
    @IBAction func clickOpenFolder(_ sender: Any) {
        let index = tableViewFile.clickedRow
        openUrl(index, isDirectory: true)
    }
}

extension MainViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return items?.count ?? 0
        }
        return (item as? DirectoryTreeModel)?.children?.count ?? 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return items?.safeObject(index: index) ?? DirectoryTreeModel()
        }
        return (item as? DirectoryTreeModel)?.children?.safeObject(index: index) ?? DirectoryTreeModel()
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return item
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let identifier = NSUserInterfaceItemIdentifier("DirectoryTreeFolderTableCellView")
        var view = outlineView.makeView(withIdentifier: identifier, owner: self) as? DirectoryTreeFolderTableCellView
        if view == nil {
            view = DirectoryTreeFolderTableCellView()
        }
        
        return view
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return (item as? DirectoryTreeModel)?.isDirectory ?? false
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 32
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let view = notification.object as? NSOutlineView
        /*
        let columns = view?.selectedColumnIndexes // ?
        let column = view?.selectedColumn ?? 0
        let rows = view?.selectedRowIndexes // ?
        let row = view?.selectedRow ?? -1
        let model = view?.item(atRow: row)
        */
        
        if let row = view?.selectedRow {
            let item = view?.item(atRow: row) as? DirectoryTreeModel
            files = sortedFile(item?.children)
            tableViewFile.reloadData()
        }
    }
}

extension MainViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return files?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellIdentifier = ""
        if tableColumn == tableView.tableColumns.safeObject(index: 0) {
            cellIdentifier = "DirectoryTreeFileNameTableCellView"
        }
        if tableColumn == tableView.tableColumns.safeObject(index: 1) {
            cellIdentifier = "DirectoryTreeFileDateTableCellView"
        }
        if tableColumn == tableView.tableColumns.safeObject(index: 2) {
            cellIdentifier = "DirectoryTreeFileSizeTableCellView"
        }
        let identifier = NSUserInterfaceItemIdentifier(cellIdentifier)
        
        let cell = tableView.makeView(withIdentifier: identifier, owner: nil)
        return cell
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        // 如果不允许同时多个key排序，则只取第一个
        sortDescriptor = tableView.sortDescriptors.first
        
        files = sortedFile(files)
        tableViewFile.reloadData()
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 32
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        //
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return files?.safeObject(index: row)
    }
}

extension MainViewController: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        let index = tableViewFile.clickedRow
        menuItemOpenFile.isEnabled = index >= 0
        menuItemOpenFolder.isEnabled = index >= 0
    }
}

extension Array {
    subscript (safeObject index: Int) -> Element? {
        return (0..<count).contains(index) ? self[index] : nil
    }
    
    func safeObject(index: Int) -> Element? {
        return (0..<count).contains(index) ? self[index] : nil
    }
}
