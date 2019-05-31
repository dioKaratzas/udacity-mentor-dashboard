//
//  OutlineView.swift
//  UdacityMentorDashboard
//
//  Created by Dionisios Karatzas on 31/05/2019.
//  Copyright © 2019 Dionisios Karatzas. All rights reserved.
//

import Cocoa

class OutlineView: NSOutlineView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    override func frameOfCell(atColumn column: Int, row: Int) -> NSRect {
        let superFrame: NSRect = super.frameOfCell(atColumn: column, row: row)
        
        if (isExpandable(item(atRow: row))) /* && isGroupRow */ {
            return NSRect(x: 6, y: superFrame.origin.y, width: bounds.size.width, height: superFrame.size.height)
        }
        return superFrame
        
    }
    
    
}

