//
//  MainViewController.swift
//  UdacityMentorDashboard
//
//  Created by Dionisios Karatzas on 17/04/2019.
//  Copyright © 2019 Dionisios Karatzas. All rights reserved.
//

import Cocoa
import KeychainAccess

class MainViewController: NSViewController, NSSplitViewDelegate, SidebarDelegate  {
    
    @IBOutlet weak var splitView: NSSplitView!
    private var tabViewController: TabViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
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
                NotificationCenter.default.post(name: NSNotification.Name("tokenIsValid"), object: nil)
            }
        } catch let error {
            print("error: \(error)")
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
            vc.delegate = self
        } else if let vc = segue.destinationController as? TabViewController {
            tabViewController = vc
        }
    }
    
    func sideBar(didSelect menu: Menu) {
        tabViewController?.switchTab(tab: menu)
    }
    
    
    
    //    @IBAction func switchViews(sender: NSButton) {
    //
    //        for sView in self.containerView.subviews {
    //            sView.removeFromSuperview()
    //        }
    //
    //        if vc1Active == true {
    //
    //            vc1Active = false
    //            let vc2 : TableViewController! = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "SubmissionsTableViewController") as? TableViewController
    //            vc2.view.frame = self.containerView.bounds
    //            self.containerView.addSubview(vc2.view)
    //
    //        } else {
    //
    //            vc1Active = true
    //            let vc1 : MonthlyStatementsViewController! = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "MonthlyStatementsViewController") as? MonthlyStatementsViewController
    //            vc1.view.frame = self.containerView.bounds
    //            self.containerView.addSubview(vc1.view)
    //        }
    //
    //    }
}

