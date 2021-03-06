//
//  TeamViewCellSubCells.swift
//  RPGAapp
//
//  Created by Jakub on 14.05.2018.
//

import Foundation
import UIKit
import CoreData

class NewAbilityCell: UITableViewCell, UITextFieldDelegate {

	var character: Character!

	weak var newAbilityDelegate: AbilityCellDelegate!

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()

		guard textField.text?.replacingOccurrences(of: " ", with: "").count != 0 else {
			return true
		}

		if let text = textField.text {
			let context = CoreDataStack.managedObjectContext
			let newAbility = NSEntityDescription.insertNewObject(forEntityName: String(describing: Ability.self), into: context) as! Ability

			newAbility.name = text
			newAbility.character = character
			newAbility.id = String(strHash(newAbility.name! + (newAbility.character?.id!)! + String(describing: Date()))) + String(myRand(1000))

			CoreDataStack.saveContext()

			newAbilityDelegate?.modifiedAbility()

			textField.text = ""

			let action = AbilityAdded(ability: newAbility)
			PackageService.pack.send(action: action)
		}

		return true
	}
}

protocol AbilityCellDelegate: class {

	func modifiedAbility()
}


class AbilityCell: UITableViewCell {

	var character: Character!

	var ability: Ability!

	var abilityDelgate: AbilityCellDelegate!

	@IBOutlet weak var stepper: UIStepper!

	override func awakeFromNib() {
		super.awakeFromNib()

		NotificationCenter.default.addObserver(self, selector: #selector(valueOfAblitityChanged(_:)), name: .valueOfAblitityChanged, object: nil)

		let removeAbilityLongPress = UILongPressGestureRecognizer(target: self, action: #selector(removeAbility(_:)))
		self.contentView.addGestureRecognizer(removeAbilityLongPress)
	}

	@objc
    func valueOfAblitityChanged(_ notification: Notification) {
		guard let idOfChanged = notification.object as? String else {
			return
		}

		if ability.id == idOfChanged {
			stepper.value = Double(ability.value)
			self.textLabel?.text = ability.name! + ": " + String(ability.value)
		}
	}

	var removeAbilityCancelled: Bool = false

	@objc
    func removeAbility(_ sender: UILongPressGestureRecognizer) {
		switch sender.state {
		case .changed:
			removeAbilityCancelled = true

		case .began:
			removeAbilityCancelled = false

			UIView.animate(withDuration: sender.minimumPressDuration, animations: {
				self.backgroundColor = .red
			})

		case .ended:
			guard !removeAbilityCancelled else {
				UIView.animate(withDuration: 0.2, animations: {
					self.backgroundColor = .white
				})

				break
			}

			let contex = CoreDataStack.managedObjectContext

			let abilityId = ability.id

			character.removeFromAbilities(ability)
			contex.delete(ability)

			CoreDataStack.saveContext()

			abilityDelgate.modifiedAbility()

			self.backgroundColor = .white

			let action = AbilityRemoved(characterId: character.id!, abilityId: abilityId!)
			PackageService.pack.send(action: action)

		case .cancelled:
			removeAbilityCancelled = true

		default:
			UIView.animate(withDuration: 0.2, animations: {
				self.backgroundColor = .white
			})
		}
	}

	@IBAction func valueChanged(_ sender: UIStepper) {
		ability.value = Int16(sender.value)

		CoreDataStack.saveContext()

		self.textLabel?.text = "\(ability.name!): \(ability.value)"

		let action = AbilityValueChanged(ability: ability)
		PackageService.pack.send(action: action)
	}
}

protocol CharacterItemCellDelegate: class {

	func modifiedItemHandler()
}

class CharacterItemCell: UITableViewCell {

	var itemHandler: ItemHandler!

	var character: Character!

	weak var itemHandlerDelegate: CharacterItemCellDelegate?

	@IBOutlet weak var stepper: UIStepper!
	@IBOutlet weak var sendButton: UIButton!

	override func awakeFromNib() {
		super.awakeFromNib()

		NotificationCenter.default.addObserver(self, selector: #selector(equipmentChanged), name: .equipmentChanged, object: nil)

		let removeItemLongPress = UILongPressGestureRecognizer(target: self, action: #selector(removeItem(_:)))
		self.contentView.addGestureRecognizer(removeItemLongPress)

		sendButton.setTitle(NSLocalizedString("Send to character", comment: ""), for: .normal)
	}

	@IBAction func sendItem(_ sender: UIButton) {
		let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sendPop") as! SendPopover

		popController.modalPresentationStyle = .popover
		popController.popoverPresentationController?.sourceView = sender

		popController.from = character
		popController.itemHandler = itemHandler

		let topView = UIApplication.topViewController()

		topView?.present(popController, animated: true, completion: nil)
	}

	@IBAction func valueChanged(_ sender: UIStepper) {

		itemHandler.count = Int64(sender.value)

		if let name = itemHandler.item?.name {
			self.textLabel?.text = "\(name) \(itemHandler.count)"
		}

		CoreDataStack.saveContext()

		let action = ItemCharacterChanged(characterId: character.id!, itemId: (itemHandler.item?.id)!, itemCount: itemHandler.count)
		PackageService.pack.send(action: action)
	}

	@objc
    func equipmentChanged() {
		if let name = itemHandler.item?.name {
			stepper.value = Double(itemHandler.count)
			self.textLabel?.text = "\(name) \(itemHandler.count)"
		}
	}

	var removeItemCancelled: Bool = false

	@objc
    func removeItem(_ sender: UILongPressGestureRecognizer) {
		switch sender.state {
		case .changed:
			removeItemCancelled = true

		case .began:
			removeItemCancelled = false

			UIView.animate(withDuration: sender.minimumPressDuration, animations: {
				self.backgroundColor = .red
			})

		case .ended:
			guard !removeItemCancelled else {
				UIView.animate(withDuration: 0.2, animations: {
					self.backgroundColor = .white
				})

				break
			}

			let contex = CoreDataStack.managedObjectContext
			let itemId = itemHandler.item?.id

			character.removeFromEquipment(itemHandler)
			contex.delete(itemHandler)

			CoreDataStack.saveContext()

			itemHandlerDelegate?.modifiedItemHandler()

			self.backgroundColor = .white

			if let characterId = character.id, let itemId = itemId {
				let action = ItemCharacterDeleted(characterId: characterId, itemId: itemId)
				PackageService.pack.send(action: action)
			}

			removeItemCancelled = false

		case .cancelled:
			removeItemCancelled = true

		default:
			UIView.animate(withDuration: 0.2, animations: {
				self.backgroundColor = .white
			})
		}
	}
}
