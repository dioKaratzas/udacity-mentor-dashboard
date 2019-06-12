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

class ReviewsViewController: NSViewController  {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var studentFeedbackLabel: NSTextField!
    @IBOutlet weak var peerFeedbackLabel: NSTextField!
    @IBOutlet weak var ratingControl: StarRatingControl!
    @IBOutlet weak var splitViewItemFeedback: NSScrollView!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var noDataLabel: NSTextField!
    
    var submissions: [Submission]?
    private var backSubmissions: Array<Submission>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        searchField.delegate = self
        
        addSearchFieldMenu()
        addTableViewMenu()
    }
    
    
    //MARK: - Private methods
    
    private func addSearchFieldMenu() {
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
    
    fileprivate func addTableViewMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Submission", action: #selector(onSubmissionClick(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Repo url", action: #selector(onRepoUrlClick(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Download Project", action: #selector(onDownloadProjectCLick(_:)), keyEquivalent: ""))
        tableView.menu = menu
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
    
    public func loadSubmissionsCompleted(force: Bool = false) {
        if  submissions == nil || force {
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
                    
                    //                var total = 0.0
                    //                for row in 0..<submissionsResult.count {
                    //                    total += submissionsResult[row].priceD
                    //                }
                    //
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
    }
    
    public func loadSubmissionsAssigned(force: Bool = false) {
        if  submissions == nil || force {
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
    
    // MARK: - Events
    
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
    
}

// MARK: - NSSearchFieldDelegate
extension ReviewsViewController: NSSearchFieldDelegate{
    
    func controlTextDidChange(_ notification: Notification) {
        
        if notification.object as? NSSearchField == searchField {
            let searchString = self.searchField.stringValue
            if searchString.isEmpty {
                self.submissions = self.backSubmissions
            }
            else {
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
    
}

// MARK: - NSMenuDelegate
extension ReviewsViewController: NSMenuDelegate {
    
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

// MARK: - NSTableViewDataSource
extension ReviewsViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return submissions?.count ?? 0
    }
    
}

// MARK: - NSTableViewDelegate
extension ReviewsViewController: NSTableViewDelegate {
    
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

