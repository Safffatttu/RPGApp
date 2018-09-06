//
//  MapViewController.swift
//  RPGAapp
//
//  Created by Jakub on 10.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import CoreData

class MapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	var imagePicker: UIImagePickerController!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let view = self.view as? SKView{
			if let mapScene = SKScene(fileNamed: "MapScene"){
				mapScene.scaleMode = .aspectFill
				
				view.presentScene(mapScene)
			
			}
		
			view.showsFPS = true
			view.showsDrawCount = true
			view.showsNodeCount = true
		}
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openImagePicker))
	}
	
	func openImagePicker(){
	
		imagePicker = UIImagePickerController()
		
		imagePicker.delegate = self
		imagePicker.sourceType = .photoLibrary
		imagePicker.allowsEditing = true
		imagePicker.modalPresentationStyle = .overCurrentContext
		
		present(imagePicker, animated: true)
		
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		imagePicker.dismiss(animated: true)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
		
		dismiss(animated:true, completion: nil)
		
		guard let imageData = UIImagePNGRepresentation(chosenImage) else { return }
		
		let map = Load.currentMap(session: Load.currentSession())
		
		let contex = CoreDataStack.managedObjectContext
		let texture =  NSEntityDescription.insertNewObject(forEntityName: String(describing: Texture.self), into: contex) as! Texture
		
		texture.data = imageData as NSData
		
		map.background = texture
		
		CoreDataStack.saveContext()
		
		NotificationCenter.default.post(name: .mapBackgroundChanged, object: nil)
		
		guard let mapId = map.id else { return }
		
		let action = MapTextureChanged(mapId: mapId)
		PackageService.pack.send(action: action)
	}
}
