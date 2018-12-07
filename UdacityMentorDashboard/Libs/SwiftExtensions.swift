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
}
