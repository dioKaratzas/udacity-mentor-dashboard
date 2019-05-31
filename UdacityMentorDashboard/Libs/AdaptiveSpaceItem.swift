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

import Foundation
import Cocoa

public class AdaptiveSpaceItem: NSToolbarItem {

    // MARK: - Life cycle
    private func doInit() {
        let adaptiveSpaceItemView = AdaptiveSpaceItemView(frame: NSRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1)))
        adaptiveSpaceItemView.adaptiveSpaceItem = self
        view = adaptiveSpaceItemView
    }

    override init(itemIdentifier: NSToolbarItem.Identifier) {
        super.init(itemIdentifier: itemIdentifier)

        doInit()

    }

    func label() -> String {
        return ""
    }

    func paletteLabel() -> String {
        return NSLocalizedString("Adaptive Space Item", comment: "Palette name when customising toolbar")
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        doInit()
    }

    // MARK: - Public methods
    public func updateWidth() {
        minSize = minSize()
        maxSize = maxSize()
    }

    // MARK: - Private methods
    private func minSize() -> NSSize {
        let items = toolbar?.items
        let index = items?.firstIndex(of: self)
        guard let unwrappedIndex = index, let unwrappedItems = items, let superviewFrame = view?.superview?.frame, superviewFrame.origin.x > 0 else {
            return minSize
        }

        guard  unwrappedItems.count > unwrappedIndex + 1 else {
            return minSize
        }

        let nextItem = unwrappedItems[unwrappedIndex + 1]
        guard let nextItemView = nextItem.view,
              let nextItemSuperview = nextItemView.superview,
              let toolbarFrame = nextItemSuperview.superview?.frame else {
            return minSize
        }

        let nextFrame = nextItemSuperview.frame
        var space = (toolbarFrame.size.width - nextFrame.size.width) / 2 - superviewFrame.origin.x - 11
        space = space >= 0.0 ? space : 0
        return NSSize(width: space, height: minSize.height)
    }

//    func minSize() -> NSSize {
//        if let items = toolbar?.items{
//            let index: Int = (items as NSArray).index(of: self)
//            if index != NSNotFound {
//                if let thisFrame  = view?.superview?.frame{
//                    if thisFrame.origin.x > 0 {
//                        var space: CGFloat = 0
//                        if items.count > index + 1 {
//                            let nextItem = items[index + 1] as? NSToolbarItem
//                            let nextFrame: NSRect? = nextItem?.view?.superview?.frame
//                            let toolbarFrame: NSRect? = nextItem?.view?.superview?.superview?.frame
//                            space = ((toolbarFrame?.size.width ?? 0.0) - (nextFrame?.size.width ?? 0.0)) / 2 - thisFrame.origin.x - 6
//                            if space < 0 {
//                                space = 0
//                            }
//                        }
//                        let size: NSSize = super.minSize
//                        return NSMakeSize(space, size.height)
//                    }
//                }
//            }
//        }
//        return super.minSize
//    }

    private func maxSize() -> NSSize {
        return NSSize(width: minSize().width, height: maxSize.height)
    }

}

class AdaptiveSpaceItemView: NSView {

    // MARK: - Properties
    var adaptiveSpaceItem: AdaptiveSpaceItem?

    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        adaptiveSpaceItem?.updateWidth()
    }

    override func viewDidMoveToWindow() {
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidResize), name: NSWindow.didResizeNotification, object: self.window)
        adaptiveSpaceItem?.updateWidth()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Notifications
    @objc func windowDidResize() {
        adaptiveSpaceItem?.updateWidth()
    }

}
