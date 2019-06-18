//
//  MyTimer.swift
//  PowerNapTimer
//
//  Created by Trevor Walker on 6/18/19.
//  Copyright © 2019 Trevor Walker. All rights reserved.
//

import Foundation

protocol MyTimerDelegate: class {
    func timerStopped()
    func timerCompleted()
    func timerSecondTicked()
}
class MyTimer: NSObject{
//Mark -- Properties
    //Delegate
    weak var timerDelegate: MyTimerDelegate?
    //Timer Remaining
    var timeRemaining: TimeInterval?
    //Timer Object we are hiding behind our wrapper
    var timer: Timer?
    //Sets timer on or off
    var isOn: Bool{
        if timeRemaining != nil{
            return true
        } else{
            return false
        }
    }
    
//Mark -- Functions
    private func secondTicked(){
        guard let timeRemaining = timeRemaining else {return}
        if timeRemaining > 0{
            self.timeRemaining = timeRemaining - 1
            timerDelegate?.timerSecondTicked()
            print(timeRemaining)
        } else{
            timer?.invalidate()
            self.timeRemaining = nil
            timerDelegate?.timerCompleted()
        }
    }
    func startTimer(time: TimeInterval){
        if isOn == false{
            self.timeRemaining = time
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (_) in
                self.secondTicked()
            })
        }
    }
    func stopTimer(){
        if isOn{
            self.timeRemaining = nil
            timer?.invalidate()
            timerDelegate?.timerStopped()
        }
    }
}
