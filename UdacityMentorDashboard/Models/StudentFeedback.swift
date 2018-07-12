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

struct StudentFeedback: Codable {

    let body: String?
    let createdAt: String?
    let graderId: Int?
    let id: Int?
    let project: Project?
    let rating: Int?
    let readAt: String?
    let rubricId: Int?
    let submissionId: Int?
    let updatedAt: String?
    let userId: Int?


    enum CodingKeys: String, CodingKey {
        case body = "body"
        case createdAt = "created_at"
        case graderId = "grader_id"
        case id = "id"
        case project
        case rating = "rating"
        case readAt = "read_at"
        case rubricId = "rubric_id"
        case submissionId = "submission_id"
        case updatedAt = "updated_at"
        case userId = "user_id"
    }

}
