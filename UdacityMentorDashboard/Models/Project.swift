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

final class Project: NSObject, Codable {
    private let _id: Int?
    private let _name: String?

    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _name = "name"
    }

    init(id: Int?, name: String?) {
        self._id = id
        self._name = name
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

    @objc dynamic var name: String {
        if let value = _name {
            return value
        } else {
            return ""
        }
    }
}
