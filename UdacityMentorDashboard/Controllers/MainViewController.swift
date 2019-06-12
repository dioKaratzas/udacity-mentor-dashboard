//
//  MainViewController.swift
//  UdacityMentorDashboard
//
//  Created by Dionisios Karatzas on 17/04/2019.
//  Copyright © 2019 Dionisios Karatzas. All rights reserved.
//

import Cocoa
import KeychainAccess

class MainViewController: NSViewController, NSSplitViewDelegate, SidebarDelegate, TokenDelegate  {
    
    @IBOutlet weak var splitView: NSSplitView!
    private var sidebar: SidebarViewController?
    private var tabViewController: TabViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkToken()
    }
    
    private func checkToken() {
        let keychain = Keychain(server: "https://review-api.udacity.com", protocolType: .https)
        do {
            let token = try keychain.getString("udacity-token")
            
            if token == nil {
                self.performSegue(withIdentifier: "showTokenController", sender: self)
            } else {
                UdacityApi.Token = token!
                
                APIClient.checkAuthorizationAccess(token: token!, completion: { result, error in
                    if result {
//                        NotificationCenter.default.post(name: NSNotification.Name("tokenIsValid"), object: nil)
                        self.onTokenValid()
                    } else if error != nil {
                        Misc.dialogOKCancel(question: error!.localizedDescription, text: "")
                    } else if !result, error == nil {
                        Misc.dialogOKCancel(question: "Invalid Token", text: "Authorization failed. Ensure that your token is valid.")
                        self.performSegue(withIdentifier: "showTokenController", sender: self)
                    }
                })
            }
        } catch let error {
            log.error("error: \(error)")
        }
    }
    
    @IBAction func onSetToken(_ sender: Any) {
        self.performSegue(withIdentifier: "showTokenController", sender: self)
    }
    
    func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
        return NSZeroRect
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let vc = segue.destinationController as? SidebarViewController {
            sidebar = vc
            vc.delegate = self
        } else if let vc = segue.destinationController as? TabViewController {
            tabViewController = vc
        } else if let vc = segue.destinationController as? TokenViewController{
            vc.delegate = self
        }
    }
    
    func sideBar(didSelect menu: Menu) {
        tabViewController?.switchTab(tab: menu)
    }
    
    func onTokenValid() {
        tabViewController?.switchTab(tab: sidebar!.selectedMenu)
    }
    
}

