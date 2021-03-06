//
//  addCharacter.swift
//  RPGAapp
//
//  Created by Jakub on 13.11.2017.
//

import Foundation
import UIKit
import Former
import CoreData


class NewCharacterForm: FormViewController {

	var name = ""
	var race = ""
	var profession = ""
	var health: Int16 = 0
	var id = ""

	let imagePicker = UIImagePickerController()

	var imageRow: ImageRowFormer<FormImageCell>!

	var textureImage: UIImage?

	var character: Character? = nil {
		didSet {
			guard let char = character else { return }

			if let cName = char.name {
				name = cName
			}

			if let cRace = char.race {
				race = cRace
			}

			if let cProfession = char.profession {
				profession = cProfession
			}

			health = char.health

			if let id = char.id {
				self.id = id
			}

			if let textureData = char.mapRepresentation?.texture?.data {
				textureImage = UIImage(data: textureData as Data)
			}
		}
	}

	override func viewDidLoad() {
	
		let nameRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) {
			$0.titleLabel.text = NSLocalizedString("Name", comment: "")
			}.onTextChanged {[unowned self] in
				self.name = $0
			}.configure {
				$0.text = self.name
		}
	
		let raceRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) {
			$0.titleLabel.text = NSLocalizedString("Race", comment: "")
			}.onTextChanged {[unowned self] in
				self.race = $0
			}.configure {
				$0.text = self.race
		}
	
		let professionRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) {
			$0.titleLabel.text = NSLocalizedString("Profession", comment: "")
			}.onTextChanged {[unowned self] in
				self.profession = $0
			}.configure {
				$0.text = self.profession
		}
	
		let healthRow = StepperRowFormer<FormStepperCell> {
			$0.titleLabel.text = NSLocalizedString("Health", comment: "")
			$0.stepper.maximumValue = 100000000
			$0.stepper.minimumValue = 0
			}.onValueChanged {[unowned self] in
				self.health = Int16($0)
			}.configure {
				$0.value = Double(health)
		}
	
		let selectImageRow = LabelRowFormer<FormLabelCell>()
			.configure {
				$0.text = NSLocalizedString("Select player texture", comment: "")
			}.onSelected {[unowned self] _ in
				self.imagePicker.delegate = self
				self.imagePicker.sourceType = .photoLibrary
				self.imagePicker.allowsEditing = true
				self.imagePicker.modalPresentationStyle = .overCurrentContext

				self.present(self.imagePicker, animated: true)
		}
	
		imageRow = ImageRowFormer<FormImageCell>(instantiateType: .Nib(nibName: "ImageRowCell"))
			.configure {[unowned self] in
				if let texture = self.character?.mapRepresentation?.texture {
					$0.image = UIImage(data: texture.data! as Data)
				}
			}.onUpdate {[unowned self] in
				if let texture = self.textureImage {
					$0.cell._imageView.image = texture
				}
		}
	
		let header = LabelViewFormer<FormLabelHeaderView>()
			.configure {
				$0.text = NSLocalizedString("Create character", comment: "")
		}
	
		let section = SectionFormer(rowFormers: [nameRow, raceRow, professionRow, healthRow, selectImageRow, imageRow])
			.set(headerViewFormer: header)
	
		let createCharacterRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell"))
			.configure {[unowned self] in
				if self.character == nil {
					$0.text = NSLocalizedString("Create new character", comment: "")
				} else {
					$0.text = NSLocalizedString("Edit character", comment: "")
				}
			}.onSelected {[unowned self] _ in
				self.addCharacter()
		}
	
		let dismissRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell")) {
			$0.centerTextLabel.textColor = .red
			}.configure {
				$0.text	= NSLocalizedString("Dismiss changes", comment: "")
			}.onSelected {[unowned self] _ in
				self.dismissView()
		}
	
		let secondSection = SectionFormer(rowFormers: [createCharacterRow, dismissRow])
	
		former.add(sectionFormers: [section, secondSection])
	
		super.viewDidLoad()
	}

	func dismissView() {
		dismiss(animated: true, completion: nil)
	}

	func addCharacter() {
		guard name != "" else {
			shakeView(self.view)
			return
		}
	
		let context = CoreDataStack.managedObjectContext
		let session = Load.currentSession()
	
		let newCharacter: Character!
		let newMapEntity: MapEntity!
	
		if let char = character, let entity = character?.mapRepresentation {
			newCharacter = char
			newMapEntity = entity
		} else {
			newCharacter = NSEntityDescription.insertNewObject(forEntityName: String(describing: Character.self), into: context) as! Character

			newCharacter.visibility = Load.currentVisibility()

			id = "\(name) \(strHash(name + UIDevice.current.name + String(describing: Date()))) \(myRand(10000))"


			newMapEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: MapEntity.self), into: CoreDataStack.managedObjectContext) as! MapEntity

			newMapEntity.character = newCharacter
			newMapEntity.id = id
			newMapEntity.map = Load.currentMap(session: session)
		}
	
		newCharacter.name = name
		newCharacter.health = health
		newCharacter.id = id
		newCharacter.profession	= profession
		newCharacter.race = race
	
		session.addToCharacters(newCharacter)
	
		CoreDataStack.saveContext()
	
		NotificationCenter.default.post(name: .reloadTeam, object: nil)
	
		let action = CharacterCreated(character: newCharacter)
		PackageService.pack.send(action: action)
	
		if let textureImage = textureImage {
			let textureData = textureImage.jpegData(compressionQuality: 0.2)! as NSData

			let texture: Texture!

			if let exisitingTexture = character?.mapRepresentation?.texture {
				texture = exisitingTexture
			} else {
				texture = NSEntityDescription.insertNewObject(forEntityName: String(describing: Texture.self), into: context) as! Texture
			}

			texture.data = textureData

			newCharacter.mapRepresentation?.texture = texture

			CoreDataStack.saveContext()
		}
	
		dismiss(animated: true, completion: nil)
	}
}

extension NewCharacterForm: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		imagePicker.dismiss(animated: true)
	}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        textureImage = info[.editedImage] as? UIImage
	
		dismiss(animated: true, completion: nil)
	
		self.imageRow.update()
    }
}
