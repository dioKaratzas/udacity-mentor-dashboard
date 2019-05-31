/*
 * Copyright 2018 Dionysios Karatzas
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Cocoa

class SidebarViewController: NSViewController {
    
    @IBOutlet weak var sidebar: OutlineView!
    public var delegate: SidebarDelegate?
    
    var menuItems = [MenuItem](
        arrayLiteral:
        MenuItem(title: "Reviews", menu: nil,
                 children: MenuItemChildren(title: "Assigned", menu: .ReviewsAssigned), MenuItemChildren(title: "Completed", menu: .ReviewsCompleted))/*,
        MenuItem(title: "Analytics", menu: .Analytics)*/
    
    )
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup notification for window losing and gaining focus
        NotificationCenter.default.addObserver(self, selector: #selector(windowLostFocus), name: NSApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(windowGainedFocus), name: NSApplication.willBecomeActiveNotification, object: nil)
        
        sidebar.expandItem(menuItems[0])
    }
    
}

extension SidebarViewController: NSOutlineViewDataSource {
    
    // Number of items in the sidebar
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        //1
        if let menuItem = item as? MenuItem {
            return menuItem.children.count
        }
        //2
        return menuItems.count
    }
    
    // Items to be added to sidebar
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let menuItem = item as? MenuItem {
            return menuItem.children[index]
        }
        
        return menuItems[index]
    }
    
    // Whether rows are expandable by an arrow
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is MenuItem {
            //            return menuItem.children.count > 0
            return true
        }
        
        return false
    }
    
    
    @objc func windowLostFocus(_ notification: Notification) {
        setRowColour(sidebar, false)
    }
    
    @objc func windowGainedFocus(_ notification: Notification) {
        setRowColour(sidebar, true)
    }
    
    // When a row is selected
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if let outlineView = notification.object as? NSOutlineView {
            setRowColour(outlineView, true)
            callDelegate(outlineView)
        }
    }
    

    func setRowColour(_ outlineView: NSOutlineView, _ windowFocused: Bool) {
        let rows = IndexSet(integersIn: 0..<outlineView.numberOfRows)
        let rowViews = rows.compactMap { outlineView.rowView(atRow: $0, makeIfNecessary: false) }
        var initialLoad = true
        
        // Iterate over each row in the outlineView
        for i in 0..<rowViews.count {
            if rowViews[i].isSelected {
                initialLoad = false
            }
            
            if windowFocused && rowViews[i].isSelected {
                rowViews[i].backgroundColor = #colorLiteral(red: 0.2823529412, green: 0.6941176471, blue: 0.6078431373, alpha: 1) // Xcode 9 asset colours
            } else if rowViews[i].isSelected {
                rowViews[i].backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            } else {
                rowViews[i].backgroundColor = .clear
            }
        }
        
        if initialLoad {
            self.setInitialRowColour()
        }
    }
    
    func callDelegate(_ outlineView: NSOutlineView){
        let rows = IndexSet(integersIn: 0..<outlineView.numberOfRows)
        let rowViews = rows.compactMap { outlineView.rowView(atRow: $0, makeIfNecessary: false) }
        
        for i in 0..<rowViews.count {
            if rowViews[i].isSelected {
                
                if let item = outlineView.item(atRow: i) as? MenuItem {
                    if item.menu != nil {
                        delegate?.sideBar(didSelect: item.menu!)
                    }
                } else if let item = outlineView.item(atRow: i) as? MenuItemChildren {
                    if item.menu != nil {
                        delegate?.sideBar(didSelect: item.menu!)
                    }
                }
                
            }
        }
                
    }
    
    func setInitialRowColour() {
        sidebar.rowView(atRow: 1, makeIfNecessary: true)?.backgroundColor = #colorLiteral(red: 0.2823529412, green: 0.6941176471, blue: 0.6078431373, alpha: 1)
        sidebar.rowView(atRow: 1, makeIfNecessary: true)?.isSelected = true
    }
    
    
}

extension SidebarViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?
        
        if let menuItem = item as? MenuItem {
            view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemCell"), owner: self) as? NSTableCellView
            if let textField = view?.textField {
                textField.stringValue = menuItem.title
//                textField.sizeToFit()
            }
        } else if let menuItem = item as? MenuItemChildren {
            view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemCell"), owner: self) as? NSTableCellView
            if let textField = view?.textField {
                textField.stringValue = menuItem.title
                textField.sizeToFit()
            }
        }
        
        return view
    }
    
    // disclosure triangle should be hidden
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return false
    }
    
    // Height of each row
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 35.0
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        if let menuItem = item as? MenuItem, menuItem.children.count > 0 {
            return false
        }
        return true
    }
    
    // Remove default selection colour
    func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
        rowView.selectionHighlightStyle = .none
    }

}

public protocol SidebarDelegate {
    func sideBar(didSelect menu: Menu)
}

public enum Menu {
    case ReviewsCompleted
    case ReviewsAssigned
    case Analytics
}

class MenuItem {
    var title: String = ""
    var children = [MenuItemChildren]()
    var menu: Menu?
    
    init(title: String, menu: Menu?, children: MenuItemChildren...) {
        self.title = title
        self.menu = menu
        for child in children {
            self.children.append(child)
        }
    }
}

class MenuItemChildren {
    var title: String = ""
    var menu: Menu?
    
    init(title: String, menu: Menu?) {
        self.title = title
        self.menu = menu
    }
}




