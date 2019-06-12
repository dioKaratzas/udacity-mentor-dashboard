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

class TabViewController: NSTabViewController {
    var reviewsViewController: ReviewsViewController?
    var test: Bool = false
    var tokenValid: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func switchTab(tab: Menu){
        switch tab {
        case .ReviewsAssigned:
            self.selectedTabViewItemIndex = 0
            (self.tabViewItems[0].viewController as! ReviewsViewController).loadSubmissionsAssigned(force: true)
        case  .ReviewsCompleted:
            self.selectedTabViewItemIndex = 1
            (self.tabViewItems[1].viewController as! ReviewsViewController).loadSubmissionsCompleted(force: false)
        case .Analytics:
            self.selectedTabViewItemIndex = 2
        }
    }

}
