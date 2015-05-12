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
    @IBOutlet var subjectView: LBGridView?
    @IBOutlet var trialLabel: NSTextField?
    @IBOutlet var conditionLabel: NSTextField?
    @IBOutlet var landmarkLabel: NSTextField?
    var currentTrial = -1
    @IBOutlet var responseField: NSTextField?
    @IBOutlet var takePictureButton: NSButton?
    @IBOutlet var nextTrialButton: NSButton?
    
    let conditions = [0:"pointing", 1:"grid"]
    let landmarks = [0:"thumbTip", 1:"thumbMCP", 2:"indexTip", 3:"indexMCP", 4:"middleTip", 5:"middleMCP", 6:"ringTip",  7:"ringMCP", 8:"littleTip", 9:"littleMCP", 10:"ulna"]
    
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
        trialLabel!.stringValue = "-"
        conditionLabel!.stringValue = "-"
        landmarkLabel!.stringValue = "-"
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
            let newSubjWindowController = GMSubjectWindowController(screenNumber: 1, andFullScreen: true)
            (document! as! GMDocument).subjectWindowController = newSubjWindowController
            newSubjWindowController.showWindow(self)
            newSubjWindowController.gridView?.cellSize = Size(width: 50, height: 50)
            newSubjWindowController.gridView?.labelCells = true
            newSubjWindowController.gridView?.needsDisplay = true
            
            subjectView?.cellSize = Size(width: 50, height: 50)
            subjectView?.labelCells = true
            subjectView?.needsDisplay = true
            
            startButton!.enabled = false
            finishButton!.enabled = false
            stopButton!.enabled = true
            nextTrialButton!.enabled = true
            nextTrial(self)
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
    
    @IBAction func nextTrial(sender: AnyObject){
        recordCurrentTrial()
        currentTrial++
        let dataMatrix = (document! as! GMDocument).experimentData.experimentDataMatrix
        if currentTrial < dataMatrix.numberOfObservations() {
            let trialSettings = dataMatrix.observationAtIndex(currentTrial)
            trialLabel!.stringValue = "\(currentTrial)"
            conditionLabel!.stringValue = "\(conditions[trialSettings[0] as! Int]!)"
            landmarkLabel!.stringValue = "\(landmarks[trialSettings[1] as! Int]!)"
            if trialSettings[0] as! Int == 0 {  //i.e. pointing task
                responseField!.enabled = false
                takePictureButton!.enabled = true
                subjectView!.gridSize = Size(width: 0, height: 0)
                subjectView!.needsDisplay = true
                ((document! as! GMDocument).subjectWindowController as! GMSubjectWindowController).gridView?.gridSize = Size(width: 0, height: 0)
                ((document! as! GMDocument).subjectWindowController as! GMSubjectWindowController).gridView?.needsDisplay = true
            } else {    //i.e. grid task
                responseField!.enabled = true
                takePictureButton!.enabled = false
                subjectView!.gridSize = subjectView!.viewSize
                subjectView!.needsDisplay = true
                ((document! as! GMDocument).subjectWindowController as! GMSubjectWindowController).gridView?.gridSize = ((document! as! GMDocument).subjectWindowController as! GMSubjectWindowController).gridView!.viewSize
                ((document! as! GMDocument).subjectWindowController as! GMSubjectWindowController).gridView?.needsDisplay = true
            }
        } else {
            nextTrialButton!.enabled = false
            trialLabel!.stringValue = "Done"
            conditionLabel!.stringValue = ""
            landmarkLabel!.stringValue = ""
        }
    }
    
    func recordCurrentTrial(){
        window!.makeFirstResponder(nil)
    }
}

