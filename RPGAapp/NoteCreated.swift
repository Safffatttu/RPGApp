//
//  NoteCreated.swift
//  RPGAapp
//
//  Created by Jakub on 05.10.2018.
//

import Foundation
import MultipeerConnectivity
import CoreData

struct NoteCreated: Action {

	var actionType: ActionType = .noteCreated
	var data: ActionData {
        let data = ActionData(dictionary: [
            "noteId": noteId,
            "noteText": noteText
            ])
        return data
	}

	var sender: MCPeerID?

	let noteId: String
	let noteText: String

	var actionData: ActionData?

	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender
	
		self.noteId = actionData.value(forKey: "noteId") as! String
		self.noteText = actionData.value(forKey: "noteText") as! String
	
		self.actionData = actionData
	}

	init(note: Note) {
		self.noteId = note.id!
		self.noteText = note.text!
	}

	func execute() {
		let context = CoreDataStack.managedObjectContext
		let note = NSEntityDescription.insertNewObject(forEntityName: String(describing: Note.self), into: context) as! Note
	
		note.id = String(strHash(String(describing: Date())))
		note.text = ""
	
		let session = Load.currentSession()
	
		note.session = session
	
		CoreDataStack.saveContext()
	
		NotificationCenter.default.post(name: .addedNote, object: nil)
	}
}
