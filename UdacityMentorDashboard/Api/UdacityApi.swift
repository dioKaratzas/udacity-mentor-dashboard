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


class UdacityApi {
    static let Format: String = ".json"
    static let EndPoint: String = "https://review-api.udacity.com/api/v1"
    static var Token: String = ""


    struct Routes {

        struct Me {
            static let Me: String = "/me"
            static let Submissions: String = Me + "/submissions"
            static let Certifications: String = Me + "/certifications"
            static let SubmissionsAssigned: String = Submissions + "/assigned"
            static let SubmissionsAssignedCount: String = Submissions + "/assigned_count"
            static let SubmissionsCompleted: String = Submissions + "/completed?limit=999"
            static let StudentFeedbacksStats: String = Me + "/student_feedbacks/stats"
            static let SubmissionsRequests: String = Me + "/submission_requests"
            static let PeerFeedback: String = Me + "/votes?submission_ids[]=%@"
            static let StudentFeedback: String = Me + "/student_feedbacks?submission_ids[]=%@"
            static let TotalEarnings: String = Me + "/earnings"
            static let Earnings: String = Me + "/earnings?start_date=%@&end_date=%@"
            static let Statements: String = Me + "/reviewer_statements?start_date=2011-01-01T00:00:00.000Z"
        }


        struct Project {
            static let ProjectInfo: String = "/projects/%d"
            static let ProjectAssignSubmission: String = ProjectInfo + "/submissions/assign"
        }


        struct Submission {
            static let SubmissionInfo: String = "/submissions/%d"
            static let SubmissionContents: String = SubmissionInfo + "/contents"
            static let SubmissionAudit: String = SubmissionInfo + "/audit"
        }

        struct SubmissionRequests {
            static let GetSubmissionRequests: String = "/submission_requests"
            static let ActionSubmissionRequests: String = GetSubmissionRequests + "/%d"
            static let SubmissionRequestsRefresh: String = ActionSubmissionRequests + "/refresh"
            static let SubmissionRequestsWait: String = ActionSubmissionRequests + "/waits"
            static let UnassignSubmissionRequests: String = ActionSubmissionRequests + "/unassign"
        }

        static let ContentComments: String = "/contents/%d" + "/comments"
        static let AuditCritiques: String = "/audits/%d/critiques"
    }

}

