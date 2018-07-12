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

struct PeerFeedback: Codable {

    let id: Int?
    let voterId: Int?
    let value: Int?
    let feedback: String?
    let submissionId: Int?
    let createdAt: String?
    let updatedAt: String?


    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case feedback = "feedback"
        case id = "id"
        case submissionId = "submission_id"
        case updatedAt = "updated_at"
        case value = "value"
        case voterId = "voter_id"
    }

}
