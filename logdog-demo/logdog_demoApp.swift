//
//  logdog_demoApp.swift
//  logdog-demo
//
//  Created by kelvinfok on 31/7/25.
//

import SwiftUI
import LogDog

@main
struct logdog_demoApp: App {
  
  init() {
    setupLogDog()
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
  
  private func setupLogDog() {
    LogDog.initialize()
    // Replace API key with your own
    let config = LogDogConfig(apiKey: "ld-prod-287f3ae8-7dc9-46cd-9bc4-3a044d0e4895", logs: true, network: true, events: true)
    LogDog.start(config: config)
    LogDog.setDebugShake(active: true)
  }
}
