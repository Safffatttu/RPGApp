//
//  TeamView.swift
//  RPGAapp
//
//  Created by Jakub on 10.08.2017.
//

import Foundation
import UIKit
import CoreData
import Dwifft

class TeamView: UICollectionViewController {
    
	var team: [Character] = Load.characters(usingVisibility: true) {
		didSet {
			diffCalculator?.items = team
		}
	}
	
	var diffCalculator: SingleSectionCollectionViewDiffCalculator<Character>?
	
    override func viewDidLoad() {
		self.diffCalculator = SingleSectionCollectionViewDiffCalculator(collectionView: self.collectionView, initialItems: team, sectionIndex: 0)
		
		let buttonLable = NSLocalizedString("Add", comment: "")
        let addButton =  UIBarButtonItem.init(title: buttonLable, style: .plain, target: self, action: #selector(addCharacter(_:)))
        self.navigationItem.rightBarButtonItem = addButton
		
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTeam), name: .reloadTeam, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(editCharacter(_:)), name: .modifyCharacter, object: nil)
		
        super.viewDidLoad()
    }
	
    @objc func addCharacter(_ sender: Any) {
        let characterFrom = NewCharacterForm()
		
		characterFrom.modalPresentationStyle = .formSheet
		characterFrom.preferredContentSize = CGSize(width: 440, height: 450)
		
        present(characterFrom, animated: true, completion: nil)
    }
	
	@objc func editCharacter(_ notification: Notification) {
		guard let character = notification.object as? Character else { return }
		
		let characterFrom = NewCharacterForm()
		
		characterFrom.character = character
		
		characterFrom.modalPresentationStyle = .formSheet
		characterFrom.preferredContentSize = CGSize(width: 440, height: 450)
		
		present(characterFrom, animated: true, completion: nil)
	}
	
    @objc func reloadTeam() {
        team = Load.characters(usingVisibility: true)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.diffCalculator?.items.count)!
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TeamViewCell
		
		let character = (self.diffCalculator?.items[indexPath.row])!
        cell.character = character
		
        return cell
    }
    
}

extension Notification.Name {
    static let reloadTeam = Notification.Name("reloadTeam")
    static let equipmentChanged = Notification.Name("equipmentChanged")
    static let modifiedAbility = Notification.Name("modifiedAbility")
	static let valueOfAblitityChanged = Notification.Name("valueOfAblitityChanged")
	static let modifyCharacter = Notification.Name("modifyCharacter")
}
