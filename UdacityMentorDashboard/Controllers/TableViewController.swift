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

class TableViewController: NSViewController, NSSearchFieldDelegate, TokenDelegate {

    //MARK: Properties
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var studentFeedbackLabel: NSTextField!
    @IBOutlet weak var peerFeedbackLabel: NSTextField!
    @IBOutlet weak var ratingControl: StarRatingControl!
    @IBOutlet weak var splitViewItemFeedback: NSScrollView!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var noDataLabel: NSTextField!

    @objc dynamic var submissions: [Submission]?
    private var backSubmissions: Array<Submission>?

    //Holds the currently selected segment control index
    private var currentSelectedIndex = 0

    var toolbar: NSToolbar!
    var toolbarTotalTv : NSTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 17))
    

    let toolbarItems: [ToolbarItemConfiguration] = [
        ToolbarItemConfiguration(title: "", iconName: nil, identifier: NSToolbarItem.Identifier(rawValue: "TinySpace")),
        ToolbarItemConfiguration(title: "", iconName: "Logo", identifier: NSToolbarItem.Identifier(rawValue: "Logo")),
        ToolbarItemConfiguration(title: "", iconName: nil, identifier: NSToolbarItem.Identifier(rawValue: "AdaptiveSpace")),
        ToolbarItemConfiguration(title: "", iconName: nil, identifier: NSToolbarItem.Identifier(rawValue: "SubmissionSwitch")),
        ToolbarItemConfiguration(title: "", iconName: nil, identifier: NSToolbarItem.Identifier(rawValue: "TinySpace")),
        ToolbarItemConfiguration(title: "", iconName: nil, identifier: NSToolbarItem.Identifier(rawValue: "SubmissionsTotal")),
    ]

    var toolbarTabsIdentifiers: [NSToolbarItem.Identifier] {
        return toolbarItems
                .compactMap {
            $0.identifier
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        tableView.menu?.delegate = self
        searchField.delegate = self
        self.createMenuForSearchField()

        checkToken()
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        if let window = NSApplication.shared.mainWindow {
            toolbar = NSToolbar(identifier: "TheToolbarIdentifier")
            toolbar.allowsUserCustomization = true
            toolbar.delegate = self

            window.toolbar = toolbar
        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let vc = segue.destinationController as? TokenViewController {
            vc.delegate = self
        }
    }

    func controlTextDidChange(_ notification: Notification) {
        if notification.object as? NSSearchField == searchField {
            let searchString = self.searchField.stringValue
            if searchString.isEmpty {
                self.submissions = self.backSubmissions
            } else {
                if (self.searchField.cell as? NSSearchFieldCell)?.placeholderString == "All" {
                    let predicate: NSPredicate = NSPredicate(format: "id contains %@ OR status contains %@ OR result contains %@ OR repoURL contains %@ OR assignedAt contains %@ OR completedAt contains %@ OR project.name contains %@ ", searchString, searchString, searchString, searchString, searchString, searchString, searchString)

                    self.submissions = (self.backSubmissions! as NSArray).filtered(using: predicate) as? [Submission] ?? self.backSubmissions
                } else if (self.searchField.cell as? NSSearchFieldCell)?.placeholderString == "Id" {
                    self.submissions = self.backSubmissions?.filter {
                        $0.id.contains(searchString)
                    }
                }
            }
            self.tableView.reloadData()
        }
    }

    func onTokenValid() {
//        loadSubmissionsCompleted()
        loadSubmissionsAssigned()
    }

    //MARK: - Private methods

    private func createMenuForSearchField() {
        let menu = NSMenu()
        menu.title = "Menu"

        let allMenuItem = NSMenuItem()
        allMenuItem.title = "All"
        allMenuItem.target = self
        allMenuItem.action = #selector(changeSearchFieldItem(_:))

        let idMenuItem = NSMenuItem()
        idMenuItem.title = "Id"
        idMenuItem.target = self
        idMenuItem.action = #selector(changeSearchFieldItem(_:))

        menu.addItem(allMenuItem)
        menu.addItem(idMenuItem)

        self.searchField.searchMenuTemplate = menu
        self.changeSearchFieldItem(allMenuItem)

    }

    private func checkToken() {
        let keychain = Keychain(server: "https://review-api.udacity.com", protocolType: .https)
        do {
            let token = try keychain.getString("udacity-token")

            if token == nil {
                self.performSegue(withIdentifier: "showTokenController", sender: self)
            } else {
                UdacityApi.Token = token!
                onTokenValid()
            }
        } catch let error {
            print("error: \(error)")
        }
    }

    private func fetchPeerFeedback(submissionId: String) {
        self.peerFeedbackLabel.stringValue = "This submission has not been peer reviewed yet."

        APIClient.peerFeedback(submissionId: submissionId, completion: { result, error in
            if let peerFeedbackResult = result, peerFeedbackResult.count > 0 {

                var text = "";
                if let voterID = peerFeedbackResult[0].voterId {
                    text = String(format: "Voter ID: %d\n\n", voterID)
                }
                text += peerFeedbackResult[0].feedback ?? "This submission has not been peer reviewed yet."


                if peerFeedbackResult[0].value == -1 {
                    self.peerFeedbackLabel.attributedStringValue = text.highlightWordsIn(highlightedWords: (peerFeedbackResult[0].feedback ?? "This submission has not been peer reviewed yet."), color: NSColor.red)
                } else {
                    self.peerFeedbackLabel.attributedStringValue = text.highlightWordsIn(highlightedWords: (peerFeedbackResult[0].feedback ?? "This submission has not been peer reviewed yet."), color: NSColor.green)
                }


            } else if error != nil {
                log.debug(error!.localizedDescription)
            }
        })
    }

    private func fetchStudentFeedback(submissionId: String) {
        self.studentFeedbackLabel.stringValue = "No comment."
        self.ratingControl.rating = 0

        APIClient.studentFeedback(submissionId: submissionId, completion: { result, error in
            if let studentFeedbackResult = result, studentFeedbackResult.count > 0 {
                self.studentFeedbackLabel.stringValue = studentFeedbackResult[0].body ?? "No comment."
                self.ratingControl.rating = studentFeedbackResult[0].rating!
            } else if error != nil {
                log.debug(error!.localizedDescription)
            }
        })
    }

    private func clearTable() {
        submissions = nil
        backSubmissions = nil
        tableView.reloadData()
        splitView.isHidden = true
        noDataLabel.isHidden = true
    }

    private func loadSubmissionsCompleted() {
        clearTable()
        self.toggleProgressIndicator(start: true)

        tableView.tableColumns[2].isHidden = false
        tableView.tableColumns[3].isHidden = false
        splitViewItemFeedback.isHidden = false

        APIClient.submissionsCompleted(completion: { result, error in
            if let submissionsResult = result, submissionsResult.count > 0 {
                self.submissions = submissionsResult
                self.backSubmissions = submissionsResult
                self.tableView.reloadData()
                self.splitView.isHidden = false
                self.noDataLabel.isHidden = true
                
                var total = 0.0
                for row in 0..<submissionsResult.count {
                    total += submissionsResult[row].priceD 
                }
                
                self.toolbarTotalTv.stringValue = "Total: \(total)"
            } else if error != nil {
                if(error!._code != -999){ // ! canceled
                    Misc.dialogOKCancel(question: error!.localizedDescription, text: "")
                }
            } else {
                self.noDataLabel.isHidden = false
            }

            self.toggleProgressIndicator(start: false)

        })
    }

    private func loadSubmissionsAssigned() {
        clearTable()
        self.toggleProgressIndicator(start: true)

        tableView.tableColumns[2].isHidden = true
        tableView.tableColumns[3].isHidden = true
        splitViewItemFeedback.isHidden = true

        APIClient.submissionsAssigned(completion: { result, error in
            if let submissionsResult = result, submissionsResult.count > 0 {
                self.submissions = submissionsResult
                self.backSubmissions = submissionsResult
                self.tableView.reloadData()
                self.splitView.isHidden = false
                self.noDataLabel.isHidden = true
            } else if error != nil {
                if(error!._code != -999){ // ! canceled
                    Misc.dialogOKCancel(question: error!.localizedDescription, text: "")
                }
            } else {
                self.noDataLabel.isHidden = false
            }

            self.toggleProgressIndicator(start: false)

        })
    }

    private func toggleProgressIndicator(start: Bool) {
        if start {
            self.progressIndicator.startAnimation(self)
            self.progressIndicator.isHidden = false
        } else {
            self.progressIndicator.stopAnimation(self)
            self.progressIndicator.isHidden = true
        }
    }

    //MARK: - Handling events

    @objc func tableViewDoubleClick(_ sender: AnyObject) {

        guard tableView.selectedRow >= 0, let item = submissions?[tableView.selectedRow] else {
            return
        }


        if let url = URL(string: "https://review.udacity.com/#!/submissions/\(String(describing: item.id))") {
            NSWorkspace.shared.open(url)
        }

    }

    @objc func changeSearchFieldItem(_ sender: AnyObject) {
        //Based on the Menu item selection in the search field the placeholder string is set
        (self.searchField.cell as? NSSearchFieldCell)?.placeholderString = sender.title
    }

    @objc func submissionsSwitch(_ sender: NSSegmentedControl) {
        if sender.indexOfSelectedItem == 0 && currentSelectedIndex != 0 {
            loadSubmissionsAssigned()
            currentSelectedIndex = 0
        } else if sender.indexOfSelectedItem == 1 && currentSelectedIndex != 1 {
            loadSubmissionsCompleted()
            currentSelectedIndex = 1
        }
    }

    @IBAction func onSubmissionClick(_ sender: Any) {
        if let itemId = submissions?[tableView.clickedRow].id, let url = URL(string: "https://review.udacity.com/#!/submissions/\(String(describing: itemId))") {
            NSWorkspace.shared.open(url)
        }
    }

    @IBAction func onRepoUrlClick(_ sender: Any) {
        if let repoUrl = submissions?[tableView.clickedRow].repoURL, let url = URL(string: repoUrl) {
            NSWorkspace.shared.open(url)
        }
    }

    @IBAction func onDownloadProjectCLick(_ sender: Any) {
        if let archiveUrl = submissions?[tableView.clickedRow].archiveURL, let url = URL(string: archiveUrl) {
            NSWorkspace.shared.open(url)
        }
    }

    @IBAction func onSetToken(_ sender: Any) {
        self.performSegue(withIdentifier: "showTokenController", sender: self)
    }

}

//MARK: Extensions

extension TableViewController: NSMenuDelegate {

    func menuWillOpen(_ menu: NSMenu) {
        if submissions != nil, tableView.clickedRow >= 0 {
            menu.item(at: 0)?.isEnabled = (submissions?[tableView.clickedRow].id != "")
            menu.item(at: 1)?.isEnabled = (submissions?[tableView.clickedRow].repoURL != "")
            menu.item(at: 2)?.isEnabled = (submissions?[tableView.clickedRow].archiveURL != "")
        } else {
            menu.item(at: 0)?.isEnabled = false
            menu.item(at: 1)?.isEnabled = false
            menu.item(at: 2)?.isEnabled = false
        }
    }

}

extension TableViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return submissions?.count ?? 0
    }

}

extension TableViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        if submissions != nil {
            let versionsAsNSMutable = NSMutableArray(array: submissions!)
            versionsAsNSMutable.sort(using: tableView.sortDescriptors)
            submissions = versionsAsNSMutable as? Array<Submission>
            tableView.reloadData()
        }

    }


    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {

        if let submissionId = submissions?[row].id {
            fetchPeerFeedback(submissionId: submissionId)
            fetchStudentFeedback(submissionId: submissionId)
        }

        return true
    }

    func tableView(_ tableView: NSTableView, sizeToFitWidthOfColumn column: Int) -> CGFloat {

        var longest: CGFloat = 0

        for row in 0..<tableView.numberOfRows {
            let view = tableView.view(atColumn: column, row: row, makeIfNecessary: true) as! NSTableCellView
            let width = view.textField!.attributedStringValue.size().width + 10

            if (longest < width) {
                longest = width
            }
        }

        return longest
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        var text: String = ""

        guard let submission = submissions?[row] else {
            return nil
        }

        if tableColumn == tableView.tableColumns[0] {
            text = String(row + 1)
        } else if tableColumn == tableView.tableColumns[1] {
            text = String(submission.id)
        } else if tableColumn == tableView.tableColumns[2] {
            text = submission.result
        } else if tableColumn == tableView.tableColumns[3] {
            text = submission.completedAt
        } else if tableColumn == tableView.tableColumns[4] {
            text = submission.project?.name ?? ""
        } else if tableColumn == tableView.tableColumns[5] {
            text = submission.repoURL
        }

        if let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }

}

extension TableViewController: NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {

        guard let toolbarItemConfig: ToolbarItemConfiguration = toolbarItems.filter({ $0.identifier.rawValue == itemIdentifier.rawValue }).first
                else {
            return nil
        }

        var toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)

        if itemIdentifier.rawValue == "Logo" {
            let imageView = NSImageView(frame: NSRect(x: 0, y: 0, width: 160, height: 37))

            if toolbarItemConfig.iconName != nil {
                let iconImage = NSImage(named: toolbarItemConfig.iconName!)
                imageView.image = iconImage
            }

            toolbarItem.view = imageView
        } else if itemIdentifier.rawValue == "SubmissionSwitch" {
            let segmented = NSSegmentedControl(frame: NSRect(x: 150, y: 0, width: 160, height: 40))
            segmented.trackingMode = .selectOne
            segmented.segmentStyle = .rounded
            segmented.segmentCount = 2

            segmented.setLabel("Assigned", forSegment: 0)
            segmented.setSelected(true, forSegment: 0)
            segmented.setLabel("Completed", forSegment: 1)
            segmented.action = #selector(submissionsSwitch)
            toolbarItem.view = segmented

        } else if itemIdentifier.rawValue == "AdaptiveSpace" {
            toolbarItem = AdaptiveSpaceItem(itemIdentifier: itemIdentifier)
        } else if itemIdentifier.rawValue == "TinySpace" {
            let spaceView = NSImageView(frame: NSRect(x: 0, y: 0, width: 5, height: 1))

            toolbarItem.view = spaceView
        } else if itemIdentifier.rawValue == "SubmissionsTotal"{
            toolbarTotalTv.font = NSFont(name: toolbarTotalTv.font!.fontName, size: 18)
            toolbarTotalTv.textColor = NSColor.darkGray
            toolbarTotalTv.usesSingleLineMode = true
            toolbarTotalTv.isEditable = false
            toolbarTotalTv.isBordered = false
            toolbarTotalTv.backgroundColor = NSColor.clear
            toolbarTotalTv.stringValue = "Total: "
            toolbarItem.view = toolbarTotalTv
        }

        return toolbarItem
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarTabsIdentifiers;
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }

    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }

    func toolbarWillAddItem(_ notification: Notification) {
        //        print("toolbarWillAddItem", (notification.userInfo?["item"] as? NSToolbarItem)?.itemIdentifier ?? "")
    }

    func toolbarDidRemoveItem(_ notification: Notification) {
        //        print("toolbarDidRemoveItem", (notification.userInfo?["item"] as? NSToolbarItem)?.itemIdentifier ?? "")
    }

}
