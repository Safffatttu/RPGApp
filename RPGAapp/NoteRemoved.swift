//
//  NoteRemoved.swift
//  RPGAapp
//
//  Created by Jakub on 05.10.2018.
//

import Foundation
import MultipeerConnectivity

struct NoteRemoved: Action {

	var actionType: ActionType = ActionType.noteRemoved
	var data: ActionData {
        let data = ActionData(dictionary: [
            "noteId": noteId
            ])
        return data
	}

	var sender: MCPeerID?

	let noteId: String

	var actionData: ActionData?

	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender
	
		self.noteId = actionData.value(forKey: "noteId") as! String
	
		self.actionData = actionData
	}

	init(noteId: String) {
		self.noteId = noteId
	}

	func execute() {
        guard let note = Load.notes().first(where: {$0.id == noteId}) else { return }
	
		let contex = CoreDataStack.managedObjectContext
	
		contex.delete(note)
	
		CoreDataStack.saveContext()
	
		NotificationCenter.default.post(name: .addedNote, object: nil)
	}
}
