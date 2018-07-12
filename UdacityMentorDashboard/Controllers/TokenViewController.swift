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
import KeychainAccess


class TokenViewController: NSViewController {
    weak var delegate: TokenDelegate?
    @IBOutlet weak var tokenText: NSTextField!

    override func viewDidLoad() {

    }

    @IBAction func onCheckToken(_ sender: Any) {
        APIClient.checkAuthorizationAccess(token: tokenText.stringValue, completion: { result, error in
            if result {
                if self.saveTokenOnKeychain() {
                    self.delegate?.onTokenValid()
                    self.dismiss(self)
                }
            } else if error != nil {
                Misc.dialogOKCancel(question: error!.localizedDescription, text: "")
            } else if !result, error == nil {
                Misc.dialogOKCancel(question: "Invalid Token", text: "Authorization failed. Ensure that your token is valid.")
            }
        })

    }


    @IBAction func onCancel(_ sender: Any) {
        if UdacityApi.Token != "" {
            self.dismiss(nil)
        } else {
            NSApplication.shared.terminate(self)
        }
    }

    private func saveTokenOnKeychain() -> Bool {
        let keychain = Keychain(server: "https://review-api.udacity.com", protocolType: .https)
        do {
            try keychain
                    .label("udacity.com (api-access-token)")
                    .comment("udacity api access token")
                    .set(tokenText.stringValue, key: "udacity-token")

            return true
        } catch let error {
            log.error("error: \(error)")
            Misc.dialogOKCancel(question: "Unexpected error", text: error.localizedDescription)
            return false
        }
    }

}

protocol TokenDelegate: class {
    func onTokenValid()
}
