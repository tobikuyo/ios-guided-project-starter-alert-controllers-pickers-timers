//
//  CountdownViewController.swift
//  Countdown
//
//  Created by Paul Solt on 5/8/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit

class CountdownViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var countdownPicker: UIPickerView!
    
    // MARK: - Properties
    
    let countdown  = Countdown()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter
    }()
    
    lazy private var countdownPickerData: [[String]] = {
        // Create string arrays using numbers wrapped in string values: ["0", "1", ... "60"]
        let minutes: [String] = Array(0...60).map { String($0) }
        let seconds: [String] = Array(0...59).map { String($0) }
        
        // "min" and "sec" are the unit labels
        let data: [[String]] = [minutes, ["min"], seconds, ["sec"]]
        return data
    }()
   
    // This should represent the amount of time selected in the picker view
    var duration: TimeInterval {
        // Grab the minutes and seconds from their respective components and convert them to a time interval
        
        let minutes = countdownPicker.selectedRow(inComponent: 0)
        let seconds = countdownPicker.selectedRow(inComponent: 2)
        let totalSeconds = TimeInterval(minutes * 60 + seconds)
        
        return totalSeconds
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        countdownPicker.delegate = self
        countdownPicker.dataSource = self
        
        countdown.delegate = self
    }
    
    // MARK: - Actions
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        countdown.start()
        updateViews()
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        countdown.reset()
        updateViews()
    }
    
    // MARK: - Private
    
    private func showAlert() {
        let finishedAlert = UIAlertController(title: "Timer Finished", message: "Your countdown is over", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        finishedAlert.addAction(action)
                
        present(finishedAlert, animated: true, completion: nil)
    }
    
    private func updateViews() {
        switch countdown.state {
        case .started:
            timeLabel.text = string(from: countdown.timeRemaining)
            startButton.isEnabled = false
        case .finished:
            timeLabel.text = string(from: 0) // Have the text be 00:00:00.00
            startButton.isEnabled = true
        case .reset:
            timeLabel.text = string(from: duration)
            startButton.isEnabled = true
        }
    }
    
    private func string(from duration: TimeInterval) -> String {
        let date = Date(timeIntervalSinceReferenceDate: duration)
        return dateFormatter.string(from: date)
    }
}

extension CountdownViewController: CountdownDelegate {
    func countdownDidUpdate(timeRemaining: TimeInterval) {
        updateViews()
    }
    
    func countdownDidFinish() {
        updateViews()
        showAlert()
    }
}

extension CountdownViewController: UIPickerViewDataSource {
    // This is really similar to the numberOfSectionsInTableView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return countdownPickerData.count
    }
    
    // Really similar to numberOfRows in section
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countdownPickerData[component].count
    }
}

extension CountdownViewController: UIPickerViewDelegate {
    
    // Similar to the cellForRow at function in a table view
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let componentArray = countdownPickerData[component]
        let timeValue = componentArray[row] // 5, min, 23, sec
        
        return timeValue
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 50
    }
    
    // This gets called every time a row is moved (and stops moving)
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countdown.duration = duration
    }
}
