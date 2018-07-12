//
//  HyperlinkTextField.swift
//  UdacityMentorDashboard
//
//  Created by Dionisios Karatzas on 21/06/2018.
//  Copyright © 2018 Dionisios Karatzas. All rights reserved.
//

import Cocoa

@IBDesignable
class HyperlinkTextField: NSTextField {

    @IBInspectable var href: String = ""

    override func resetCursorRects() {
        discardCursorRects()
        addCursorRect(self.bounds, cursor: NSCursor.pointingHand)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // TODO:  Fix this and get the hover click to work.

        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.foregroundColor: NSColor.blue,
            NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue as AnyObject
        ]
        attributedStringValue = NSAttributedString(string: self.stringValue, attributes: attributes)
    }

    override func mouseDown(with theEvent: NSEvent) {
        if let localHref = URL(string: href) {
            NSWorkspace.shared.open(localHref)
        }
    }
}
