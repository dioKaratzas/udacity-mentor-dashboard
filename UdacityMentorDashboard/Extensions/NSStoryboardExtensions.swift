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

extension NSStoryboard {

    /**
     Get the application's main storyboard
     ```
     // Usage:
     let storyboard = NSStoryboard.mainStoryboard
     ```
     */
    public static var mainStoryboard: NSStoryboard! {
        return NSStoryboard(name:"Main", bundle: Bundle.main)
    }

    /**
     Get view controller from storyboard by its class type
     
     Warning: identifier should match storyboard ID in storyboard of identifier class
     
     ```
     // Usage:
     let profileVC = storyboard!.instantiateVC(ProfileViewController) //  profileVC is of type ProfileViewController
     ```
     */
    public func instantiateVC<T>(_ identifier: T.Type) -> T? {
        let storyboardID = String(describing: identifier)
        if let vc = instantiateController(withIdentifier: storyboardID) as? T {
            return vc
        } else {
            return nil
        }
    }
}
