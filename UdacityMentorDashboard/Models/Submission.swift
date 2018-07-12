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

final class Submission: NSObject, Codable {
    private let _id: Int?
    private let _status: String?
    private let _result: String?
    private let _repoURL: String?
    private let _assignedAt: String?
    private let _price: String?
    private let _completedAt: String?
    private let _archiveURL: String?
    private let _project: Project?

    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _status = "status"
        case _result = "result"
        case _repoURL = "repo_url"
        case _assignedAt = "assigned_at"
        case _price = "price"
        case _completedAt = "completed_at"
        case _archiveURL = "archive_url"
        case _project = "project"
    }

    init(id: Int?, status: String?, result: String?, repoURL: String?, assignedAt: String?, price: String?, completedAt: String?, archiveURL: String?, project: Project?) {
        self._id = id
        self._status = status
        self._result = result
        self._repoURL = repoURL
        self._assignedAt = assignedAt
        self._price = price
        self._completedAt = completedAt
        self._archiveURL = archiveURL
        self._project = project
        super.init()
    }

    // MARK: Getters
    @objc dynamic var id: String {
        if let value = _id {
            return String(value)
        } else {
            return ""
        }
    }

    @objc dynamic var status: String {
        if let value = _status {
            return value
        } else {
            return ""
        }
    }

    @objc dynamic var result: String {
        if let value = _result {
            return value
        } else {
            return ""
        }
    }

    @objc dynamic var repoURL: String {
        if let value = _repoURL {
            return value
        } else {
            return ""
        }
    }

    @objc dynamic var assignedAt: String {
        if let value = _assignedAt, let date = Date.getFormattedDate(string: value, formatterGet: "yyyy-MM-dd'T'HH:mm:ss.zzzZ", formatterPrint: "MM/dd/yyyy") {
            return date
        } else {
            return ""
        }
    }

    @objc dynamic var price: String {
        guard let price = _price, let value = Double(price) else {
            return "";
        }

        return String(format: "$ %.02f", value)
    }

    @objc dynamic var completedAt: String {
        if let value = _completedAt, let date = Date.getFormattedDate(string: value, formatterGet: "yyyy-MM-dd'T'HH:mm:ss.zzzZ", formatterPrint: "MM/dd/yyyy") {
            return date
        } else {
            return ""
        }
    }


    @objc dynamic var archiveURL: String {
        if let value = _archiveURL {
            return value
        } else {
            return ""
        }
    }

    @objc dynamic var project: Project? {
        return _project
    }
}
