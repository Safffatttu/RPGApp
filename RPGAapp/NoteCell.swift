//
//  NoteCell.swift
//  RPGAapp
//
//  Created by Jakub on 04.10.2018.
//

import Foundation
import UIKit

class NoteCell: UICollectionViewCell, UITextViewDelegate{
	
	@IBOutlet weak var textView: UITextView!

	var note: Note!{
		didSet{
			textView.text = note.text
		}
	}
	
	override func awakeFromNib() {
		let removeNoteLongPress = UILongPressGestureRecognizer(target: self, action: #selector(removeNote(_:)))
		textView.addGestureRecognizer(removeNoteLongPress)
		
		NotificationCenter.default.addObserver(self, selector: #selector(changeText), name: .changedNote, object: nil)
		
		super.awakeFromNib()
	}
	
	var removeNoteCancelled: Bool = false
	
	@objc func removeNote(_ sender: UILongPressGestureRecognizer){
		switch sender.state {
		case .changed:
			removeNoteCancelled = true
			
		case .began:
			removeNoteCancelled = false
			
			UIView.animate(withDuration: sender.minimumPressDuration, animations: {
				self.textView.backgroundColor = .red
			})
			
		case .ended:
			guard !removeNoteCancelled else {
				UIView.animate(withDuration: 0.2, animations: {
					self.textView.backgroundColor = .lightGray
				})
				
				break
			}
			
			textView.backgroundColor = .lightGray
			
			let noteId = note.id!
			
			let contex = CoreDataStack.managedObjectContext
			contex.delete(note)
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .addedNote, object: nil)
			
			let action = NoteRemoved(noteId: noteId)
			PackageService.pack.send(action: action)
		case .cancelled:
			removeNoteCancelled = true
			
		default:
			UIView.animate(withDuration: 0.2, animations: {
				self.textView.backgroundColor = .lightGray
			})
		}
	}
	
	func textViewDidChange(_ textView: UITextView) {
		note.text = textView.text
		CoreDataStack.saveContext()
		
		let action = NoteTextChanged(note: note)
		PackageService.pack.send(action: action)
	}
	
	@objc func changeText(_ notification: Notification){
		guard let changedNote = notification.object as? Note else { return }
		guard note == changedNote else { return }
		
		textView.text = note.text
	}
}
