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
    
    override var windowNibName: String! {
        return "GMExperimenterWindow"
    }
    
    @IBAction func startExperiment(sender: AnyObject){
        sender.window.makeFirstResponder(nil)
        println("Start experiment")
        (document! as! GMDocument).experimentData.experimentName = experimentNameField().stringValue
//        println("\((document! as! GMDocument).experimentData.experimentName)")
        (document! as! GMDocument).experimentData.experimentSubject = experimentSubjectField().stringValue
        (document! as! GMDocument).experimentData.experimentSession = experimentSessionField().stringValue
        (document! as! GMDocument).experimentData.experimentFilenameStem = experimentFilenameStemField().stringValue
        (document! as! GMDocument).experimentData.experimentDate = experimentDatePicker().dateValue
        let fileDate = DRHFileDate(date: (document! as! GMDocument).experimentData.experimentDate)
        var fileName = "\((document! as! GMDocument).experimentData.experimentFilenameStem)_"
        fileName += "\((document! as! GMDocument).experimentData.experimentSubject)"
        fileName += "\((document! as! GMDocument).experimentData.experimentSession)"
        fileName += "\(fileDate.dateString())"
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = fileName
        savePanel.extensionHidden = false
        let result = savePanel.runModal()
        if result == NSModalResponseOK {
            //save the document as .gridmarks
            //write the experimentData as text
                //new LabBot method?
            //store the path in experimentData so files can be saved.
                //maybe this comes from document!.path?
            //set up any directory structure
        }
        
 /*
        if (result) {
        [[self document] saveToURL:[savePanel URL] ofType:@"com.drh.landExp" forSaveOperation:NSSaveOperation delegate:self didSaveSelector:@selector(document:didSave:contextInfo:) contextInfo:nil];
        }
        }];
*/
    }
    
}

