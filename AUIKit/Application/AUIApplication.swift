//
//  AUIApplication.swift
//  AUIKit
//
//  Created by Ihor Myroniuk on 6/6/19.
//

import UIKit

public protocol AUIApplication: UIApplicationDelegate where Self: UIApplication {
  
  // MARK: Launching
  
  func willFinishLaunching()
  func willFinishLaunchingNotification(payload: [AnyHashable: Any])
  func willFinishLaunchingLocation()
  func willFinishLaunchingShortcutItem(_ shortcutItem: UIApplicationShortcutItem)
  func didFinishLaunching()
  func didFinishLaunchingNotification(payload: [AnyHashable: Any])
  func didFinishLaunchingLocation()
  func didFinishLaunchingShortcutItem(_ shortcutItem: UIApplicationShortcutItem)
  func willOpenURL(_ url: URL)
  
  // MARK: States
  
  func willEnterForeground()
  func didBecomeActive()
  func willResignActive()
  func didEnterBackground()
  func willTerminate()
  
  // MARK: Memory
  
  func didReceiveMemoryWarning()
  
}
