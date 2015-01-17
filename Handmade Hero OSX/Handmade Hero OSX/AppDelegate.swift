//
//  AppDelegate.swift
//  Handmade Hero OSX
//
//  Created by Karl Kirch on 12/28/14.
//  Copyright (c) 2014 Handmade Hero. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var gameView: GameView!
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        window.aspectRatio = window.frame.size;
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    
    func applicationDidBecomeActive(notification: NSNotification) {
        gameView.setAppIsActive(true)
    }
    
    func applicationDidResignActive(notification: NSNotification) {
        gameView.setAppIsActive(false)
    }

}

