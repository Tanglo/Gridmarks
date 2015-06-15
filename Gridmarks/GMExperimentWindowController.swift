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
    let spokenInstructions = [
        "point_thumbTip":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("pointThumbTipAudio", ofType: "m4a")!)!),
        "point_thumbMCP":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("pointThumbMCPAudio", ofType: "m4a")!)!),
        "point_indexTip":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("pointIndexTipAudio", ofType: "m4a")!)!),
        "point_indexMCP":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("pointIndexMCPAudio", ofType: "m4a")!)!),
        "point_middleTip":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("pointMiddleTipAudio", ofType: "m4a")!)!),
        "point_middleMCP":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("pointMiddleMCPAudio", ofType: "m4a")!)!),
        "point_ringTip":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("pointRingTipAudio", ofType: "m4a")!)!),
        "point_ringMCP":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("pointRingMCPAudio", ofType: "m4a")!)!),
        "point_littleTip":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("pointLittleTipAudio", ofType: "m4a")!)!),
        "point_littleMCP":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("pointLittleMCPAudio", ofType: "m4a")!)!),
        "point_ulna":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("pointUlnaAudio", ofType: "m4a")!)!),
        "handInLap":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("handInLapAudio", ofType: "m4a")!)!),
        "grid_thumbTip":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gridThumbTipAudio", ofType: "m4a")!)!),
        "grid_thumbMCP":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gridThumbMCPAudio", ofType: "m4a")!)!),
        "grid_indexTip":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gridIndexTipAudio", ofType: "m4a")!)!),
        "grid_indexMCP":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gridIndexMCPAudio", ofType: "m4a")!)!),
        "grid_middleTip":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gridMiddleTipAudio", ofType: "m4a")!)!),
        "grid_middleMCP":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gridMiddleMCPAudio", ofType: "m4a")!)!),
        "grid_ringTip":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gridRingTipAudio", ofType: "m4a")!)!),
        "grid_ringMCP":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gridRingMCPAudio", ofType: "m4a")!)!),
        "grid_littleTip":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gridLittleTipAudio", ofType: "m4a")!)!),
        "grid_littleMCP":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gridLittleMCPAudio", ofType: "m4a")!)!),
        "grid_ulna":DRHAudioPlayer(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gridUlnaAudio", ofType: "m4a")!)!)
    ]
    
    var pointingImage: NSBitmapImageRep?
    
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
        
        spokenInstructions["handInLap"]!.setPlaybackDidEndSelector("enableNextTrialButton", withObject: self)
        spokenInstructions["handInLap"]!.shouldCallPlaybackDidEndSelector = true
        let test1 = spokenInstructions["handInLap"]!
    }
    
    override func experimentIsFinished() -> Bool {
        return finishedExperiment
    }

    @IBAction func startExperiment(sender: AnyObject){
        sender.window.makeFirstResponder(nil)
//        println("Starting experiment")
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
                fileName += "\((document! as! GMDocument).experimentData.experimentSubject)_"
                fileName += "\((document! as! GMDocument).experimentData.experimentSession)_"
                fileName += "\(fileDate.dateString())"
                let savePanel = NSSavePanel()
                savePanel.nameFieldStringValue = fileName
                savePanel.directoryURL = NSURL(fileURLWithPath: (document! as! GMDocument).experimentData.experimentPath)
                savePanel.extensionHidden = false
                let result = savePanel.runModal()
                if result == NSModalResponseOK {
                    //save the gridmarks document
//                    println("\(savePanel.URL!.path!)")
                    let saveURL = NSURL(fileURLWithPath: savePanel.URL!.path! + ".gridmarks")!
//                    println("\(saveURL)")
                    (document! as! GMDocument).saveToURL(saveURL, ofType: "com.LDW.gridmarks", forSaveOperation: NSSaveOperationType.SaveAsOperation, completionHandler: {(error:NSError!) -> Void in
                        if error != nil {
                            println("\(error.description)")
                        } /*else {
                            println("Saved")
                        }*/
                        })
                    
                    //write the experimentData as text
                    let savePath = savePanel.URL!.path! + ".txt"
                    (document! as! GMDocument).experimentData.writeExperimentDataTo(savePath)
                    
                    //store the path in experimentData so files can be saved.
                    (document! as! GMDocument).experimentData.experimentPath = savePanel.URL!.path!.stringByDeletingLastPathComponent

                    //set up any directory structure
                    (document! as! GMDocument).experimentData.createExperimentSubdirectory((document! as! GMDocument).experimentData.experimentFilenameStem + " images")
                    
                    saved = true
                } else {
                    return
                }
            }
            let newSubjWindowController = GMSubjectWindowController(screenNumber: 1, andFullScreen: true)
            (document! as! GMDocument).subjectWindowController = newSubjWindowController
            newSubjWindowController.showWindow(self)
            newSubjWindowController.gridView?.cellSize = LBSize(width: 20.0, height: 20.0)
            newSubjWindowController.gridView?.labelSize = 10.0
            newSubjWindowController.gridView?.lineWidth = 0.5
            newSubjWindowController.gridView?.labelCells = true
            newSubjWindowController.gridView?.shuffleLabels = true
            newSubjWindowController.gridView?.flipVertically = true
            newSubjWindowController.gridView?.flipHorizontally = true
            newSubjWindowController.gridView?.centreHorizontally = false
            newSubjWindowController.gridView?.gridRect.origin.x = 260.0
            newSubjWindowController.gridView?.hexLabels = true
            newSubjWindowController.gridView?.needsDisplay = true
            
            subjectView?.cellSize = LBSize(width: 50, height: 50)
            subjectView?.labelCells = true
            subjectView?.needsDisplay = true
            
            experimentNameField().enabled = false
            experimentSubjectField().enabled = false
            experimentSessionField().enabled = false
            experimentFilenameStemField().enabled = false
            experimentDatePicker().enabled = false
            cameraPopup!.enabled = false
            
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
//        println("Stopping experiment")
        
        stopButton!.enabled = false
        startButton!.enabled = true
        finishButton!.enabled = true
    }
    
    @IBAction func finishExperiment(sender: AnyObject){
//        println("Finishing experiment")
        
        exportData()
        
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
        if recordCurrentTrial() || sender is GMExperimentWindowController {
            
            currentTrial++
            let dataMatrix = (document! as! GMDocument).experimentData.experimentDataMatrix
            if currentTrial < dataMatrix.numberOfObservations() {
                let trialSettings = dataMatrix.observationAtIndex(currentTrial)
                trialLabel!.stringValue = "\(currentTrial)"
                conditionLabel!.stringValue = "\(conditions[trialSettings[0] as! Int]!)"
                landmarkLabel!.stringValue = "\(landmarks[trialSettings[1] as! Int]!)"
                var audioName: String?
                if trialSettings[0] as! Int == 0 {  //i.e. pointing task
                    responseField!.enabled = false
                    takePictureButton!.enabled = true
                    nextTrialButton!.enabled = false
                    subjectView!.gridRect.size = NSSize(width: 0, height: 0)
                    subjectView!.needsDisplay = true
                    ((document! as! GMDocument).subjectWindowController as! GMSubjectWindowController).gridView?.blank = true
                    ((document! as! GMDocument).subjectWindowController as! GMSubjectWindowController).gridView?.needsDisplay = true
                    audioName = "point_" + landmarks[trialSettings[1] as! Int]!
                } else {    //i.e. grid task
                    responseField!.enabled = true
                    takePictureButton!.enabled = false
                    subjectView!.gridRect.size = NSSize(width: subjectView!.viewSize.width, height: subjectView!.viewSize.height)
                    subjectView!.needsDisplay = true
                    ((document! as! GMDocument).subjectWindowController as! GMSubjectWindowController).gridView?.blank = false
                    ((document! as! GMDocument).subjectWindowController as! GMSubjectWindowController).gridView?.gridRect.size = NSSize(width: 1500, height: 1060)
                    ((document! as! GMDocument).subjectWindowController as! GMSubjectWindowController).gridView?.needsDisplay = true
                    window?.makeFirstResponder(responseField)
                    audioName = "grid_" + landmarks[trialSettings[1] as! Int]!
                }
                if audioName != nil {
                    spokenInstructions[audioName!]!.play()
                } else {
                    NSBeep()
                }
            } else {
                nextTrialButton!.enabled = false
                trialLabel!.stringValue = "Done"
                conditionLabel!.stringValue = ""
                landmarkLabel!.stringValue = ""
            }
        }
    }


    func recordCurrentTrial() -> Bool{
        window!.makeFirstResponder(nil)
        if currentTrial < 0 {
            return false
        }
        let trialData = (document! as! GMDocument).experimentData.experimentDataMatrix.observationAtIndex(currentTrial)
        var newValue: AnyObject = Double.NaN
        if trialData[0] as! Int == 0 {  //point task
            if pointingImage != nil {
                println("Pointing image")
                newValue = pointingImage!
                pointingImage = nil
            } else {
                let alert = NSAlert()
                alert.messageText = "No image to record"
                alert.addButtonWithTitle("Whoops!")
                alert.informativeText = "There is no image ready to record, perhaps you forgot to push the \"Take picture\' button"
                alert.runModal()
                return false
            }
        } else {
            let response = responseField!.stringValue
//            println("response: \(response)")
            if response != ""{
                let (x,y) = ((document! as! GMDocument).subjectWindowController as! GMSubjectWindowController).gridView!.gridReferenceOfLabel(response)
//                println("\(x),\(y)")
                if x != nil {
                    newValue = LBPoint(point:(x!,y!))
                    responseField!.stringValue = ""
                } else {
                    let alert = NSAlert()
                    alert.messageText = "Your response is too big"
                    alert.addButtonWithTitle("Whoops!")
                    alert.informativeText = "The response you typed in is not on the grid."
                    alert.runModal()
                    return false
                }
            } else {
                let alert = NSAlert()
                alert.messageText = "No response to record"
                alert.addButtonWithTitle("Whoops!")
                alert.informativeText = "There is no response ready to record, perhaps you forgot to type it in the box"
                alert.runModal()
                return false
            }
        }
        (document! as! GMDocument).experimentData.experimentDataMatrix.changeDataPoint("response", observation: currentTrial, newValue: newValue)
        document!.saveDocument(self)
        return true
    }
    
    @IBAction func takePicture(sender: AnyObject){
        var videoConnection: AVCaptureConnection?
        let camera = (document! as! GMDocument).camera
        for captureConnection in camera.stillImageOutput().connections {
            for port in (captureConnection as! AVCaptureConnection).inputPorts {
                if port.mediaType == AVMediaTypeVideo {
                    videoConnection = captureConnection as? AVCaptureConnection
                }
            }
            if videoConnection != nil {break}
        }
        
        camera.stillImageOutput().captureStillImageAsynchronouslyFromConnection(videoConnection!, completionHandler: { (sampleBuffer: CMSampleBuffer!, error: NSError!) -> Void in
            let exifAttachments = CMGetAttachment(sampleBuffer, kCGImagePropertyExifDictionary, nil)
            if (exifAttachments != nil) {
                //use attachments
            }
            let captureImageData = AVCaptureStillImageOutput .jpegStillImageNSDataRepresentation(sampleBuffer)
            self.pointingImage = NSBitmapImageRep(data: captureImageData)
            })
        spokenInstructions["handInLap"]!.play()
        takePictureButton!.enabled = false
    }
    
    func exportData() {
        let dataMatrix = (document! as! GMDocument).experimentData.experimentDataMatrix
        var dataString = "condition, landmark, response\n"
        let numObs = dataMatrix.numberOfObservations()
        for i in 0..<numObs {
            let observation = dataMatrix.observationAtIndex(i)
            dataString += "\(observation[0]), \(observation[1]), "
            if (observation[0] as! Int) == 0 {    //pointing task
                if observation[2] is NSBitmapImageRep {
                    let pngData = (observation[2] as! NSBitmapImageRep).representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [NSObject: AnyObject]())
                    let fileName = "\((document! as! GMDocument).experimentData.experimentSubject)_Trial-\(i).png"
                    let filePath = "\((document! as! GMDocument).experimentData.experimentPath)/\((document! as! GMDocument).experimentData.experimentFilenameStem) images/\(fileName)"
                    pngData!.writeToFile(filePath, atomically: true)
                    dataString += "\(fileName)"
                }
            } else {                    //grid task
                if observation[2] is LBPoint {
                    dataString += "\(Int((observation[2] as! LBPoint).x)), \(Int((observation[2] as! LBPoint).y))"
                }
            }
            dataString += "\n"
        }
        var filePath = "\((document! as! GMDocument).experimentData.experimentPath)/"
        filePath += "\((document! as! GMDocument).experimentData.experimentFilenameStem)_"
        filePath += "\((document! as! GMDocument).experimentData.experimentSubject)_"
        filePath += "\((document! as! GMDocument).experimentData.experimentSession)_"
        let fileDate = DRHFileDate(date: (document! as! GMDocument).experimentData.experimentDate)
        filePath += "\(fileDate.dateString())"
        filePath += "_data.csv"
        println("\(filePath)")
        var writeError: NSError?
        if !dataString.writeToFile(filePath, atomically: true, encoding: NSUnicodeStringEncoding, error: &writeError) {
            let errorAlert = NSAlert(error: writeError!)
            errorAlert.runModal()
        }
        
    }
    
    func enableNextTrialButton(){
        nextTrialButton!.enabled = true
    }
}

