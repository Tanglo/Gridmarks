//
//  AppDelegate.swift
//  Gridmarks
//
//  Created by Lee Walsh on 8/05/2015.
//  Copyright (c) 2015 Lee David Walsh. All rights reserved.
//

import Cocoa
import LabBot

@NSApplicationMain
class AppDelegate: LBExperimentDelegate {
    
    override func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSApplication.sharedApplication().presentationOptions = NSApplicationPresentationOptions.HideMenuBar | NSApplicationPresentationOptions.HideDock

    }

}

