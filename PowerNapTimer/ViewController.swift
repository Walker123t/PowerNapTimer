//
//  ViewController.swift
//  PowerNapTimer
//
//  Created by Trevor Walker on 6/18/19.
//  Copyright © 2019 Trevor Walker. All rights reserved.
//

import UIKit
import UserNotifications
class ViewController: UIViewController {

    let timer = MyTimer()
    
//Mark -- UNIQUE Identifier for our notification
    fileprivate var userNotificationIdentifier = "timerFinishedNotification"
//Mark -- Outlets
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTimer()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        timer.timerDelegate = self
    }
    @IBAction func startButton(_ sender: Any) {
        if timer.isOn{
            timer.stopTimer()
        } else{
            timer.startTimer(time: 5)
            scheduleLocalNotification()
        }
        updateLabel()
        updateButton()
    }
    func updateLabel(){
        if timer.isOn{
            timeLabel.text = "\(timer.timeRemaining)"
        } else{
            timeLabel.text = "20:00"
        }
    }
    func updateButton(){
        if timer.isOn{
            button.setTitle("Stop Timer", for: .normal)
        }else{
            button.setTitle("Start Timer", for: .normal)
        }
    }
    func updateTimer(){
        UNUserNotificationCenter.current().getPendingNotificationRequests { (request) in
            //found our notification from our identifier
            let ourNotification = request.filter{$0.identifier == self.userNotificationIdentifier}
            // get notification from array
            guard let timerNotificationRequest = ourNotification.first,
            //get trigger date
            let trigger = timerNotificationRequest.trigger as? UNCalendarNotificationTrigger,
                //get the exact date
                let fireDate = trigger.nextTriggerDate() else {return}
            //turn off timer incase still running
            self.timer.stopTimer()
            //set timer to fire date
            self.timer.startTimer(time: fireDate.timeIntervalSinceNow)
        }
        
        
    }
}
//Mark -- DELEGATE FUNCTIONS
extension ViewController: MyTimerDelegate{
    func timerStopped() {
        updateLabel()
        updateButton()
    }
    
    func timerCompleted() {
        updateLabel()
        updateButton()
        displaySnoozeAlert()
    }
    
    func timerSecondTicked() {
        updateLabel()
    }
}
//Mark -- ALERT CONTROLLER
extension ViewController{
    func displaySnoozeAlert(){
        let alertController = UIAlertController(title: "Get UP", message: "Karl is gonna throw shade at you...", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Snooze for how long?"
            textField.keyboardType = .numberPad
        }
        let snoozeAction = UIAlertAction(title: "Snooze", style: .default) { (_) in
            guard let timeText = alertController.textFields?.first?.text, let time = TimeInterval(timeText) else {return}
            self.timer.startTimer(time: time * 60)
            self.scheduleLocalNotification()
            self.updateLabel()
            self.updateButton()
        }
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alertController.addAction(snoozeAction)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
//Mark -- NOTIFICATION CONTROLLER
extension ViewController{
    func scheduleLocalNotification(){
        let notificationContent = UNMutableNotificationContent()
        //set up current notification
        notificationContent.title = "Karl is gonna be pissed"
        notificationContent.subtitle = "Your late to class"
        notificationContent.badge = 999
        notificationContent.sound = .default
        //Setup when notification should fire
        guard let timeRemaining = timer.timeRemaining else {return}
        //get date components
        let date = Date(timeInterval: timeRemaining, since: Date())
        
        // get date component from fireDate
        let dateComponenet = Calendar.current.dateComponents([.minute, .second], from: date)
        //creates trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching:dateComponenet, repeats: false)
        //creates request for notifiction for our notification with our identifies
        let request = UNNotificationRequest(identifier: userNotificationIdentifier, content: notificationContent, trigger: trigger)
        //adding notification
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error
            {
                print(error.localizedDescription)
            }        }
    }
    func calcelocalNotification(){
        //removing notification from the notification center
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [userNotificationIdentifier])
    }
}
