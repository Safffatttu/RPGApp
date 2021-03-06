//
//  NewNoteCell.swift
//  RPGAapp
//
//  Created by Jakub on 04.10.2018.
//

import Foundation
import UIKit
import CoreData

class NewNoteCell: UICollectionViewCell {

	@IBOutlet weak var button: UIButton!

	override func awakeFromNib() {
		button.setTitle("", for: .normal)
		button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)

		super.awakeFromNib()
	}

	@IBAction func addNewNote() {
		let context = CoreDataStack.managedObjectContext
		let note = NSEntityDescription.insertNewObject(forEntityName: String(describing: Note.self), into: context) as! Note

		note.id = String(strHash(String(describing: Date())))
		note.text = ""

		let session = Load.currentSession()

		note.session = session

		CoreDataStack.saveContext()

		NotificationCenter.default.post(name: .addedNote, object: nil)

		let action = NoteCreated(note: note)
		PackageService.pack.send(action: action)
	}
}
