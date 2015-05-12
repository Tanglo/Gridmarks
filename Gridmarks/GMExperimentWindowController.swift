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
        experimentNameField().stringValue = (document! as! GMDocument).experimentData.experimentName
        experimentSubjectField().stringValue = (document! as! GMDocument).experimentData.experimentSubject
        experimentSessionField().stringValue = (document! as! GMDocument).experimentData.experimentSession
        experimentDatePicker().dateValue = (document! as! GMDocument).experimentData.experimentDate
        experimentFilenameStemField().stringValue = (document! as! GMDocument).experimentData.experimentFilenameStem
        if (document! as! GMDocument).fileURL != nil {
            saved = true
        }
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
                initialiseExperiment()
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
                    //save the gridmarks document
                    println("\(savePanel.URL!.path!)")
                    let saveURL = NSURL(fileURLWithPath: savePanel.URL!.path! + ".gridmarks")!
                    println("\(saveURL)")
                    (document! as! GMDocument).saveToURL(saveURL, ofType: "com.LDW.gridmarks", forSaveOperation: NSSaveOperationType.SaveAsOperation, completionHandler: {(error:NSError!) -> Void in
                        if error != nil {
                            println("\(error.description)")
                        } else {
                            println("Saved")
                        }
                        })
                    
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
    
    @IBAction func startCamera(sender: AnyObject){
        (document! as! GMDocument).camera.selectDeviceAtIndex(sender.indexOfSelectedItem())
        if !(document! as! GMDocument).camera.startCameraSession() {
            let alert = NSAlert()
            alert.messageText = "Could not start the camera"
            alert.addButtonWithTitle("Bugger")
            alert.informativeText = "Something is wrong with the camera, it couldn't be started"
            alert.runModal()
        }
    }
    
    func initialiseExperiment(){
        var baseTrials: [[AnyObject]] = [[0,0],[0,1],[0,2],[0,3],[0,4],[0,5],[0,6],[0,7],[0,8],[0,9],[0,10]]
        baseTrials += [[1,0],[1,1],[1,2],[1,3],[1,4],[1,5],[1,6],[1,7],[1,8],[1,9],[1,10]] as [[AnyObject]]
        var trialMatrix = [[AnyObject]]()
        for i in 0..<5 {
            trialMatrix += baseTrials
        }
        let dataMatrix = LBDataMatrix(variableNames: ["condition","landmark"], observations: trialMatrix)
        var responseArray = Array<AnyObject>(count: 110, repeatedValue: Double.NaN)
        dataMatrix.appendVariable("response", values: responseArray)
        dataMatrix.shuffleObservations()
        (document! as! GMDocument).experimentData.experimentDataMatrix = dataMatrix
    }
}

