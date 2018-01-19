//
//  RepeatingTimer.swift
//  tempos
//
//  Created by João Gradim on 19/01/2018.
//  Copyright © 2018 Life on Mars. All rights reserved.
//

import Foundation

// https://medium.com/@danielgalasko/a-background-repeating-timer-in-swift-412cecfd2ef9
class RepeatingTimer {
  
  private lazy var timer: DispatchSourceTimer = {
    let t = DispatchSource.makeTimerSource()
    t.schedule(deadline: .now(), repeating: .seconds(60))
    t.setEventHandler(handler: { [weak self] in
      self?.eventHandler?()
    })
    return t
  }()
  
  var eventHandler: (() -> Void)?
  
  private enum State {
    case suspended
    case resumed
  }
  
  private var state: State = .suspended
  
  deinit {
    timer.setEventHandler {}
    timer.cancel()
    /*
     If the timer is suspended, calling cancel without resuming
     triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
     */
    resume()
    eventHandler = nil
  }
  
  func resume() {
    if state == .resumed {
      return
    }
    state = .resumed
    timer.resume()
  }
  
  func suspend() {
    if state == .suspended {
      return
    }
    state = .suspended
    timer.suspend()
  }
  
}
