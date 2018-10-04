//
//  NoteCell.swift
//  RPGAapp
//
//  Created by Jakub on 04.10.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import UIKit

class NoteCell: UICollectionViewCell, UITextViewDelegate{
	
	@IBOutlet weak var textView: UITextView!

	var note: Note!{
		didSet{
			print(note.text as Any)
			textView.text = note.text
		}
	}
	
	override func awakeFromNib() {
		let removeNoteLongPress = UILongPressGestureRecognizer(target: self, action: #selector(removeNote(_:)))
		textView.addGestureRecognizer(removeNoteLongPress)
		super.awakeFromNib()
	}
	
	var removeNoteCancelled: Bool = false
	
	func removeNote(_ sender: UILongPressGestureRecognizer){
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
			
			let contex = CoreDataStack.managedObjectContext
			contex.delete(note)
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .addedNote, object: nil)
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
	}
	
}
