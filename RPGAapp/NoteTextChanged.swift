//
//  NoteTextChanged.swift
//  RPGAapp
//
//  Created by Jakub on 05.10.2018.
//

import Foundation
import MultipeerConnectivity

struct NoteTextChanged: Action {
	
	var actionType: ActionType = ActionType.noteTextChanged
	var data: ActionData {
		get {
			let data = ActionData(dictionary: [
				"noteId": noteId,
				"noteText": noteText
				])
			return data
		}
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
		guard let note = Load.note(with: noteId) else { return }
		
		note.text = ""
		
		CoreDataStack.saveContext()
		
		NotificationCenter.default.post(name: .changedNote, object: note)
	}
}
