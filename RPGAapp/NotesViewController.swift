//
//  NotesViewController.swift
//  RPGAapp
//
//  Created by Jakub on 04.10.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import UIKit
import Dwifft

class NotesViewController: UICollectionViewController{
	
	var notes: [Note] = Load.notes(){
		didSet{
			noteDiffCalculator.items = notes
		}
	}
	
	var noteDiffCalculator: SingleSectionCollectionViewDiffCalculator<Note>!
	
	override func viewDidLoad() {
		 noteDiffCalculator = SingleSectionCollectionViewDiffCalculator(collectionView: collectionView, initialItems: notes, sectionIndex: 0)
		
		NotificationCenter.default.addObserver(self, selector: #selector(reloadNotes), name: .addedNote, object: nil)
	}
	
	func reloadNotes(){
		notes = Load.notes()
	}
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return noteDiffCalculator.items.count + 1
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		print(indexPath.row)
		if indexPath.row == noteDiffCalculator.items.count{
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newNoteCell", for: indexPath) as! NewNoteCell
			return cell
		}else{
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noteCell", for: indexPath) as! NoteCell
			print(noteDiffCalculator.items.count)
			let note = noteDiffCalculator.items[indexPath.row]
			
			cell.note = note
			
			return cell
		}
	}	
}
