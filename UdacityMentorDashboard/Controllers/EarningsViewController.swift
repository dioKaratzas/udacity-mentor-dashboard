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
import Charts

class EarningsViewController: NSViewController, ChartViewDelegate {
    @IBOutlet weak var totalEarningsLabel: NSTextField!
    @IBOutlet weak var yearEarningsLabel: NSTextField!
    @IBOutlet weak var yearPopUp: NSPopUpButton!
    @IBOutlet weak var barChartCiew: BarChartView!

    var barChartEntries: [BarChartDataEntry] = []
    var statements: [Statement]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barChartCiew.delegate = self
        fetchTotalEarnings()
        fetchStatements()
        
        let year = Calendar.current.component(.year, from: Date())
        yearPopUp.removeAllItems()
        for i in 2011...year {
            yearPopUp.addItem(withTitle: String(i))
        }
        yearPopUp.select(yearPopUp.lastItem)
        onSelectYear(self)
    }

    deinit {
        log.info("\(self.className) deinit called")
    }

    //MARK: - Private methods
    private func fetchTotalEarnings() {
        APIClient.totalEarnings(completion: { result, error in
            if let totalEarnings = result {
                self.totalEarningsLabel.stringValue = "Total Earnings: $ \(totalEarnings.earnings)"
            } else if error != nil {
                if(error!._code != -999){ // ! canceled
                    Misc.dialogOKCancel(question: error!.localizedDescription, text: "")
                }
            }
        })
    }
    
    private func fetchStatements(){
        APIClient.statements ( completion: { result, error in
            if let statements = result {
                self.statements = statements
            } else if error != nil {
                if(error!._code != -999){ // ! canceled
                    Misc.dialogOKCancel(question: error!.localizedDescription, text: "")
                }
            }
        })
    }
    
    private func fillChart(earnings: [Int: Double]){
        
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"]
        let sorted = earnings.sorted { $0.key < $1.key }
        let values : [Double] = Array(sorted.map({ $0.value }))
        
        //: ### General
        barChartCiew.pinchZoomEnabled          = false
        barChartCiew.drawBarShadowEnabled      = false
        barChartCiew.doubleTapToZoomEnabled    = false
        barChartCiew.fitBars                   = false
        barChartCiew.drawGridBackgroundEnabled = false
        barChartCiew.drawBordersEnabled = false
        barChartCiew.legend.enabled = false
        
        let xAxisFormatter = XAxisChartFormatter(labels: months)
        let yAxisChartFormatter = YAxisChartFormatter(suffix: "$ ")
       
        barChartCiew.xAxis.labelTextColor = #colorLiteral(red: 1, green: 0.4078431373, blue: 0.3490196078, alpha: 1)
        barChartCiew.xAxis.drawGridLinesEnabled = false
        barChartCiew.xAxis.drawAxisLineEnabled = false
        barChartCiew.xAxis.labelCount = months.count
        barChartCiew.xAxis.valueFormatter = xAxisFormatter
        barChartCiew.xAxis.labelFont = NSUIFont.systemFont(ofSize: CGFloat(14.0))
        barChartCiew.xAxis.labelPosition = .bottomInside
        
        barChartCiew.leftAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        barChartCiew.leftAxis.drawAxisLineEnabled = false
        barChartCiew.leftAxis.labelFont = NSUIFont.systemFont(ofSize: CGFloat(14.0))
        barChartCiew.leftAxis.valueFormatter = yAxisChartFormatter
        
        barChartCiew.rightAxis.enabled = false
//        barChartCiew.rightAxis.drawAxisLineEnabled = false
//        barChartCiew.rightAxis.labelFont = NSUIFont.systemFont(ofSize: CGFloat(14.0))
//        barChartCiew.rightAxis.drawGridLinesEnabled = false
//        barChartCiew.rightAxis.valueFormatter = yAxisChartFormatter
        

        
        
        //: ### BarChartDataEntry
        barChartEntries.removeAll()
        for i in 0..<12
        {
            barChartEntries.append(BarChartDataEntry(x: Double(i), y: values[i]))
        }
        //: ### BarChartDataSet
        var set1 = BarChartDataSet()
        set1 = BarChartDataSet(entries: barChartEntries, label: nil)
        set1.colors = ChartColorTemplates.vordiplom()
        set1.drawValuesEnabled = true
        
        set1.valueFont = NSUIFont.systemFont(ofSize: CGFloat(14.0))
        set1.valueTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        
        var dataSets = [ChartDataSet]()
        dataSets.append(set1)
        
        
        
        //: ### BarChartData
        let data = BarChartData(dataSets: dataSets)
        barChartCiew.data = data
        
        barChartCiew.animate(xAxisDuration: 0.6, yAxisDuration: 0.6, easingOption: .easeInSine)
    }
    
    private func getDaysOfMonth(year: Int, month: Int) -> Int{
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        return numDays
    }

    // MARK: - Events, ChartViewDelegate
    @IBAction func onSelectYear(_ sender: Any) {
        let selectedYear = Int(yearPopUp.titleOfSelectedItem ?? "2011")!
        var earnings: [Int: Double]  = [:]
        var yearEarnings = 0.0
        let group = DispatchGroup()
        group.enter()

        for i in 1...12 {
            APIClient.earnings(year: selectedYear, month: i, monthDays: getDaysOfMonth(year: selectedYear, month: i), completion: { (Earnings, Error) in
                if let result = Earnings {
                    earnings[i] = result.earnings.toDouble
                    yearEarnings += result.earnings.toDouble
                } else if Error != nil {
                    if(Error!._code != -999){ // ! canceled
                        Misc.dialogOKCancel(question: Error!.localizedDescription, text: "")
                    }
                    earnings[i] = 0.0
                }

                if earnings.count == 12 {
                    group.leave()
                }
            });
        }

        group.notify(queue: .main) {
            self.yearEarningsLabel.stringValue = "\(self.yearPopUp.titleOfSelectedItem!) Earnings: $ \(yearEarnings)"

            self.fillChart(earnings: earnings)
        }
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if entry is BarChartDataEntry, let index = barChartEntries.firstIndex(of: entry as! BarChartDataEntry) {
            if statements != nil {
                for statement in statements! {
                    if statement.year == Int(yearPopUp.titleOfSelectedItem ?? "2011")!, statement.month == index + 1, let url = URL(string: statement.archiveUrl) {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
    }

}

private class XAxisChartFormatter: NSObject, IAxisValueFormatter {

    var labels: [String] = []

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return labels[Int(value)]
    }

    init(labels: [String]) {
        super.init()
        self.labels = labels
    }
}

private class YAxisChartFormatter: NSObject, IAxisValueFormatter {

    var suffix: String

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return suffix + String(value.toInt())
    }

    init(suffix: String) {
        self.suffix = suffix
        super.init()
    }
}