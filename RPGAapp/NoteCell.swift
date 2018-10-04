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
		
		super.awakeFromNib()
	}
	
	func textViewDidChange(_ textView: UITextView) {
		note.text = textView.text
		CoreDataStack.saveContext()
	}
	
}
