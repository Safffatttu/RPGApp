//
//  MapScene.swift
//  RPGAapp
//
//  Created by Jakub on 16.05.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import SpriteKit

class MapScene: SKScene{
	
	var cam: SKCameraNode!
	
	var selectedNode: SKSpriteNode? = nil
		
	var map: Map!{
		didSet{
			DispatchQueue.global().sync {
			
			var entities = self.map.entities?.allObjects as! [MapEntity]
			
			let visibility = Load.currentVisibility()
			
				entities = entities.filter{$0.character?.visibility == nil
										|| $0.character?.visibility == visibility}
				
			var newMapThings: [(MapEntity,SKSpriteNode)] = []
			
			for e in entities{
				let newSprite = SKSpriteNode(entity: e)
				newSprite.name = e.character?.name
				newMapThings.append((e,newSprite))
				
				self.addChild(newSprite)
			}
			
			self.mapThings = newMapThings
			
			}
		}
	}
	
	var mapThings: [(MapEntity,SKSpriteNode)] = []
	
	var mapa: SKSpriteNode!
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		
		cam = SKCameraNode()
		self.camera = cam
		self.addChild(cam)
		
		map = Load.currentMap(session: Load.currentSession())
		
		if let backgroundTexture = map.background{
			let image = UIImage(data: backgroundTexture.data! as Data)
			let texture = SKTexture(image: image!)
			mapa = SKSpriteNode(texture: texture)
		}
		else{
			mapa = SKSpriteNode(imageNamed: "mapImperium")
		}
		
		mapa.name = "mapa"
		self.addChild(mapa)
		mapa.zPosition = -1
		let imgW = mapa.size.width
		let viewW = self.size.width
		
		let scaleFactor = viewW/imgW
		
		mapa.setScale(scaleFactor)
		
		mapa.isUserInteractionEnabled = false
		
		let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchRec(sender:)))
		pinch.cancelsTouchesInView = false
		self.view?.addGestureRecognizer(pinch)
		
		let rotation = UIRotationGestureRecognizer(target: self, action: #selector(rotationRec(sender:)))
		rotation.cancelsTouchesInView = false
		self.view?.addGestureRecognizer(rotation)
		
		NotificationCenter.default.addObserver(self, selector: #selector(mapEntityMoved(_:)) , name: .mapEntityMoved, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadEntities), name: .reloadTeam, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadBackground), name: .mapBackgroundChanged, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(textureChanged(_:)), name: .mapEntityTextureChanged, object: nil)
	}
	
	func mapEntityMoved(_ sender: Notification){
		guard let object = sender.object as? (MapEntity, CGPoint) else { return }
		
		let entity = object.0
		let newPos = object.1
		
		guard let sprite = mapThings.filter({$0.0 == entity}).first?.1 else { return }
		
		let moveToAction = SKAction.move(to: newPos, duration: 0.4)
		
		sprite.run(moveToAction)
	}
	
	func textureChanged(_ sender: Notification){
		var sprite: SKSpriteNode!
		
		var textureData: Data!
		
		if let entity = sender.object as? MapEntity{
			sprite = mapThings.first(where: {$0.0 == entity})?.1
			
			textureData = entity.texture?.data as Data?
		}else{
			sprite = self.mapa
			textureData = map.background?.data as Data?
		}
		
		guard let image = UIImage(data: textureData) else { return }
		
		let texture = SKTexture(image: image)
		
		let textureReloadSeq = SKAction.sequence([
			SKAction.fadeOut(withDuration: 0.4),
			SKAction.run{
				sprite.texture = texture
			},
			SKAction.fadeIn(withDuration: 0.4)
			])
		
		sprite.run(textureReloadSeq)
	}
	
	func reloadEntities(){
		for sprite in mapThings.map({$0.1}){
			sprite.run(SKAction.hide())
		}
		map = Load.currentMap(session: Load.currentSession())
	}
	
	func reloadBackground(){
		if let backgroundTexture = map.background{
			let image = UIImage(data: backgroundTexture.data! as Data)
			let texture = SKTexture(image: image!)
			let actionSeq = SKAction.sequence([
				SKAction.fadeOut(withDuration: 0.4),
				SKAction.run{
					self.mapa.texture = texture
				},
				SKAction.fadeIn(withDuration: 0.4)
			])
			mapa.run(actionSeq)
		}
		else{
			mapa.texture = SKTexture(imageNamed: "mapImperium")
		}
	}
	
	var previousScale: CGFloat = 1
	
	func pinchRec(sender: UIPinchGestureRecognizer){
		
		if sender.state == .began{
			previousScale = cam.xScale
		}
		
		cam.xScale = previousScale * 1 / sender.scale
		cam.yScale = cam.xScale
		
	}
	
	func rotationRec(sender: UIRotationGestureRecognizer){
		cam.zRotation = sender.rotation
	}
	
	func touchDown(atPoint pos : CGPoint) {
		
	}
	
	func touchMoved(toPoint pos : CGPoint) {
		
	}
	
	func touchUp(atPoint pos : CGPoint) {
		
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches {
			let positionInScene = t.location(in: self)
			
			selectNodeForTouch(touchLocation: positionInScene)
		}
	}
	
	func selectNodeForTouch(touchLocation: CGPoint){
		let touchedNode = self.atPoint(touchLocation)
		
		guard mapThings.map({$0.1}).contains(touchedNode) else {
			selectedNode?.removeAllActions()
			selectedNode = nil
			return
		}
		
		selectedNode = touchedNode as? SKSpriteNode
		
		let sendPositionAction = SKAction.run {
				if let node = self.selectedNode{
					self.sendPositionData(node: node)
			}
		}
		
		let sequence = SKAction.sequence([SKAction.scale(by: 2, duration: 0.4),
		                                  sendPositionAction,
										  SKAction.scale(by: 2, duration: 0.4).reversed(),
										  sendPositionAction])

		selectedNode?.run(SKAction.repeatForever(sequence))
	}
	
	func degToRad(degree: Double) -> CGFloat {
		return CGFloat(Double(degree) / 180.0 * 3.1415926535)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else {
			return
		}
		
		if let node = selectedNode {
		
			let positionInScene = touch.location(in: self)
			let previousPosition = touch.previousLocation(in: self)
			let translation = CGPoint(x: positionInScene.x - previousPosition.x, y: positionInScene.y - previousPosition.y)
			
			panForTranslation(translation: translation,node: node)
		}else{
			
			let location = touch.location(in: self)
			let previousLocation = touch.previousLocation(in: self)
			
			camera?.position.x += previousLocation.x - location.x
			camera?.position.y += previousLocation.y - location.y
		}
		
		for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
	}
	
	func panForTranslation(translation: CGPoint, node: SKSpriteNode) {
		let position = node.position
		
		node.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let node = selectedNode{
			let scaleFactor = 30/node.size.width
			
			let scaleBack = SKAction.scale(by: scaleFactor, duration: 0.2)

			node.removeAllActions()
			node.run(scaleBack)
			
			let entity = mapThings.filter({$0.1 == node}).first?.0
			entity?.x = Double(node.position.x)
			entity?.y = Double(node.position.y)
			
			CoreDataStack.saveContext()
			
			sendPositionData(node: node)
						
			selectedNode = nil
		}
		
		for t in touches { self.touchUp(atPoint: t.location(in: self)) }
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchUp(atPoint: t.location(in: self)) }
	}
	
	
	override func update(_ currentTime: TimeInterval) {
		// Called before each frame is rendered
	}
	
	func sendPositionData(node: SKSpriteNode){
		let action = NSMutableDictionary()
		let at = NSNumber(value: ActionType.mapEntityMoved.rawValue)
		
		action.setValue(at, forKey: "action")
		action.setValue(Double(node.position.x), forKey: "posX")
		action.setValue(Double(node.position.y), forKey: "posY")
		
		let entityId = mapThings.filter({$0.1 == node}).first!.0.id!
		action.setValue(entityId, forKey: "entityId")
		
		PackageService.pack.send(action)
	}
	
}

extension Notification.Name{
	static let mapEntityMoved = Notification.Name("mapEntityMoved")
	static let mapBackgroundChanged = Notification.Name("mapBackgroundChanged")
	static let mapEntityTextureChanged = Notification.Name("mapEntityTextureChanged")
}
