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
import Alamofire

class APIClient {

    static func checkAuthorizationAccess(token: String, completion: @escaping (Bool, Error?) -> Void) {
        UdacityApi.Token = token

        AF.request(ApiRouter.Me)
                .responseJSON { response in
                    switch response.result {
                    case .success( _):
                        DispatchQueue.main.async {
                            if response.response?.statusCode == 401 {
                                completion(false, nil)
                            } else {
                                completion(true, nil)
                            }
                        }
                    case .failure(let error):
                        log.error(error)
                        DispatchQueue.main.async {
                            completion(false, error)
                        }
                    }
                }
    }

    static func submissionsCompleted(completion: @escaping ([Submission]?, Error?) -> Void) {
        request(apiRouter: ApiRouter.SubmissionsCompleted, completion: completion)
    }

    static func submissionsAssigned(completion: @escaping ([Submission]?, Error?) -> Void) {
        request(apiRouter: ApiRouter.SubmissionsAssigned, completion: completion)
    }

    static func peerFeedback(submissionId: String, completion: @escaping ([PeerFeedback]?, Error?) -> Void) {
        request(apiRouter: ApiRouter.PeerFeedback(id: submissionId), completion: completion)
    }

    static func studentFeedback(submissionId: String, completion: @escaping ([StudentFeedback]?, Error?) -> Void) {
        request(apiRouter: ApiRouter.StudentFeedback(id: submissionId), completion: completion)
    }
    
    static func totalEarnings(completion: @escaping (Earnings?, Error?) -> Void) {
        request(apiRouter: ApiRouter.TotalEarnings, completion: completion)
    }
    
    static func earnings(year: Int, month: Int, monthDays: Int, completion: @escaping (Earnings?, Error?) -> Void) {
        request(apiRouter: ApiRouter.Earnings(stardDate: "%22\(year)-\(month)-01T00:00:00.000Z%22", endDate: "%22\(year)-\(month)-\(monthDays)T23:59:59.000Z%22"), completion: completion)
    }
    
    static func statements(completion: @escaping ([Statement]?, Error?) -> Void) {
        request(apiRouter: ApiRouter.Statements, completion: completion)
    }
    
    static private func cancelAllRequests(){
//        AF.Session.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
//            sessionDataTask.forEach { $0.cancel() }
//            uploadData.forEach { $0.cancel() }
//            downloadData.forEach { $0.cancel() }
//        }
    }


    private static func request<T: Decodable>(apiRouter: ApiRouter, completion: @escaping (T?, Error?) -> Void) {
        cancelAllRequests()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        AF.request(apiRouter)
            .responseDecodable(queue: DispatchQueue.global(qos: .userInitiated), decoder: decoder) { (response: DataResponse<T>) in
//                     Print Alamofire Response Json
//                    if let data = response.data {
//                     let json = String(data: data, encoding: String.Encoding.utf8)
//                     log.debug("Failure Response: \(json)")
//                     }
                    switch response.result {
                    case .success(let value):
                        DispatchQueue.main.async {
                            completion(value, nil)
                        }
                    case .failure(let error):
                        log.error(error)
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                }
    }
}
