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

final class Statement: Codable {
    private let _id: Int?
    private let _userId: Int?
    private let _startDate: String?
    private let _endDate: String?
    private let _archiveUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _userId = "user_id"
        case _startDate = "start_date"
        case _endDate = "end_date"
        case _archiveUrl = "archive_url"
    }
    
    // MARK: Getters
    var year: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.zzzZ"
        
        if let value = _startDate, let date = formatter.date(from: value) {
            let calendar = Calendar.current.dateComponents([.year], from: date)
            return calendar.year ?? 0
        }
        return 0
        
    }
    
    var month: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.zzzZ"
        
        if let value = _startDate, let date = formatter.date(from: value) {
            let calendar = Calendar.current.dateComponents([.month], from: date)
            return calendar.month ?? 0
        }
        return 0
        
    }
    
    var archiveUrl: String {
        if let url = _archiveUrl {
            return url
        }
        return ""
    }
    
}
