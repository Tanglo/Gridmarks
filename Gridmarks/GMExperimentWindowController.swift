//
//  GMExperimentWindowController.swift
//  Gridmarks
//
//  Created by Lee Walsh on 8/05/2015.
//  Copyright (c) 2015 Lee David Walsh. All rights reserved.
//

import Cocoa
import LabBot

class GMExperimentWindowController: DRHExperimenterWindowController {
    var saved = false
    var finishedExperiment = false
    @IBOutlet var cameraPopup: NSPopUpButton?
    @IBOutlet var subjectView: GMSubjectView?
    
    override var windowNibName: String! {
        return "GMExperimenterWindow"
    }
    
    override func windowDidLoad() {
        cameraPopup!.removeAllItems()
        let cameras = (document! as! GMDocument).camera.availableDevices()
        for currentCamera in cameras {
            cameraPopup!.addItemWithTitle(currentCamera.localizedName!!)
        }
        cameraPopup!.selectItem(nil)
    }
    
    override func experimentIsFinished() -> Bool {
        return finishedExperiment
    }

    @IBAction func startExperiment(sender: AnyObject){
        sender.window.makeFirstResponder(nil)
        println("Starting experiment")
        if cameraPopup!.selectedItem != nil {
            if !saved {
                (document! as! GMDocument).experimentData.experimentName = experimentNameField().stringValue
                (document! as! GMDocument).experimentData.experimentSubject = experimentSubjectField().stringValue
                (document! as! GMDocument).experimentData.experimentSession = experimentSessionField().stringValue
                (document! as! GMDocument).experimentData.experimentFilenameStem = experimentFilenameStemField().stringValue
                (document! as! GMDocument).experimentData.experimentDate = experimentDatePicker().dateValue
                let fileDate = DRHFileDate(date: (document! as! GMDocument).experimentData.experimentDate)
                var fileName = "\((document! as! GMDocument).experimentData.experimentFilenameStem)_"
                fileName += "\((document! as! GMDocument).experimentData.experimentSubject)"
                fileName += "\((document! as! GMDocument).experimentData.experimentSession)"
                fileName += "_\(fileDate.dateString())"
                let savePanel = NSSavePanel()
                savePanel.nameFieldStringValue = fileName
                savePanel.directoryURL = NSURL(fileURLWithPath: (document! as! GMDocument).experimentData.experimentPath)
                savePanel.extensionHidden = false
                let result = savePanel.runModal()
                if result == NSModalResponseOK {
                    //write the experimentData as text
                    let savePath = savePanel.URL!.path! + ".txt"
                    (document! as! GMDocument).experimentData.writeExperimentDataTo(savePath)
                    
                    //store the path in experimentData so files can be saved.
                    (document! as! GMDocument).experimentData.experimentPath = savePanel.URL!.path!.stringByDeletingLastPathComponent

                    //set up any directory structure
                    (document! as! GMDocument).experimentData.createExperimentSubdirectory((document! as! GMDocument).experimentData.experimentSession + " images")
                    
                    saved = true
                    experimentNameField().enabled = false
                    experimentSubjectField().enabled = false
                    experimentSessionField().enabled = false
                    experimentFilenameStemField().enabled = false
                    experimentDatePicker().enabled = false
                    cameraPopup!.enabled = false
                } else {
                    return
                }
            }
            startButton!.enabled = false
            finishButton!.enabled = false
            stopButton!.enabled = true
            let newSubjWindowController = GMSubjectWindowController(screenNumber: 1, andFullScreen: true)
            (document! as! GMDocument).subjectWindowController = newSubjWindowController
            newSubjWindowController.showWindow(self)
        } else {
            let alert = NSAlert()
            alert.messageText = "No camera is running."
            alert.addButtonWithTitle("Hmmm")
            alert.informativeText = "There is currently no camera running.  Perhaps you haven't yet selected one."
            alert.runModal()
        }
    }
    
    @IBAction func stopExperiment(sender: AnyObject){
        println("Stopping experiment")
        
        stopButton!.enabled = false
        startButton!.enabled = true
        finishButton!.enabled = true
    }
    
    @IBAction func finishExperiment(sender: AnyObject){
        println("Finishing experiment")
        
        startButton!.enabled = false
        finishButton!.enabled = false
        finishedExperiment = true
    }
    
}

