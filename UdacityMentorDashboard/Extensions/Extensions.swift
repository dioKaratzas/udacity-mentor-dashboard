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

extension Date {

    static func getFormattedDate(string: String, formatterGet: String, formatterPrint: String) -> String? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = formatterGet

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = formatterPrint

        if let date: Date = dateFormatterGet.date(from: string) {
            return dateFormatterPrint.string(from: date);
        } else {
            return nil;
        }
    }

}

extension String {

    func highlightWordsIn(highlightedWords: String, color: NSColor) -> NSMutableAttributedString {
        let range = (self as NSString).range(of: highlightedWords)
        let result = NSMutableAttributedString(string: self)


        result.addAttributes([NSAttributedString.Key.foregroundColor: color], range: range)


        return result
    }
    
    var toDouble: Double {
        return Double(self) ?? 0.0
    }
}

extension Double {
    
    func toInt() -> Int {
        return Int(self)
    }
    
}

extension NSTextView {
    override open func performKeyEquivalent(with event: NSEvent) -> Bool {
        let commandKey = NSEvent.ModifierFlags.command.rawValue
        let commandShiftKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue
        if event.type == NSEvent.EventType.keyDown {
            if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandKey {
                switch event.charactersIgnoringModifiers! {
                case "x":
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to:nil, from:self) { return true }
                case "c":
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to:nil, from:self) { return true }
                case "v":
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to:nil, from:self) { return true }
                case "z":
                    if NSApp.sendAction(Selector(("undo:")), to:nil, from:self) { return true }
                case "a":
                    if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to:nil, from:self) { return true }
                default:
                    break
                }
            } else if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandShiftKey {
                if event.charactersIgnoringModifiers == "Z" {
                    if NSApp.sendAction(Selector(("redo:")), to:nil, from:self) { return true }
                }
            }
        }
        return super.performKeyEquivalent(with: event)
    }
}
