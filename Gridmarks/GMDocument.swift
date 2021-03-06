//
//  Document.swift
//  Gridmarks
//
//  Created by Lee Walsh on 8/05/2015.
//  Copyright (c) 2015 Lee David Walsh. All rights reserved.
//

import Cocoa
import LabBot

class GMDocument: DRHExperimentDocument {
    var experimentData = DRHExperimentData()
    var camera = DRHStillCamera()

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
        subjectWindowController = nil
    }
    
    override func newExperimenterWindowController() -> AnyObject! {
        return GMExperimentWindowController()
    }

    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override func dataOfType(typeName: String, error outError: NSErrorPointer) -> NSData? {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
 //       outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
 //       return nil
        return NSKeyedArchiver.archivedDataWithRootObject(experimentData)
    }

    override func readFromData(data: NSData, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
//        outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
//        return false
        let newExperimentData = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! DRHExperimentData
        
        experimentData = newExperimentData
        return true
    }
    
}

