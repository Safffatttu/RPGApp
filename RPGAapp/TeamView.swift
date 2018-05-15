//
//  TeamView.swift
//  RPGAapp
//
//  Created by Jakub on 10.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Dwifft

class TeamView: UICollectionViewController {
    
	var team: [Character] = Load.characters(){
		didSet{
			diffCalculator?.items = team
		}
	}
	
	var diffCalculator: SingleSectionCollectionViewDiffCalculator<Character>?
	
    override func viewDidLoad() {
		self.diffCalculator = SingleSectionCollectionViewDiffCalculator(collectionView: self.collectionView, initialItems: team, sectionIndex: 0)
        let addButton =  UIBarButtonItem.init(title: "Add", style: .plain, target: self, action: #selector(addCharacter(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTeam), name: .reloadTeam, object: nil)
        super.viewDidLoad()
    }
	
    func addCharacter(_ sender: Any){
        if !sessionIsActive(){
            return
        }
        let addCharControler = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addCharacter")
        addCharControler.modalPresentationStyle = .formSheet
        self.present(addCharControler, animated: true, completion: nil)
    }
	
    func reloadTeam(){
        team = Load.characters()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.diffCalculator?.items.count)!
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TeamViewCell
		
		let person = (self.diffCalculator?.items[indexPath.row])!
        cell.nameLabel.text = person.name
		cell.character = person
        return cell
    }
    
}

extension Notification.Name{
    static let reloadTeam = Notification.Name("reloadTeam")
    static let equipmentChanged = Notification.Name("equipmentChanged")
    static let modifiedAbility = Notification.Name("modifiedAbility")
	static let valueOfAblitityChanged = Notification.Name("valueOfAblitityChanged")

}
