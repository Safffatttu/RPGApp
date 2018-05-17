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
			let things = map.entities?.allObjects as! [MapEntity]
			
			var newMapEntities: [(MapEntity,SKSpriteNode)] = []
			
			for t in things{
				let newSprite = SKSpriteNode(entity: t, parent: self)
				newSprite.name = t.character?.name
				newMapEntities.append((t,newSprite))
			}
			
			mapThings = newMapEntities
		}
	}
	
	var mapThings: [(MapEntity,SKSpriteNode)] = []
	
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		
		cam = SKCameraNode()
		self.camera = cam
		self.addChild(cam)
		
		map = Load.currentMap(session: getCurrentSession())
		
		let mapa = SKSpriteNode(imageNamed: "mapa")
		mapa.name = "mapa"
		self.addChild(mapa)
		print(self.size)
		mapa.zPosition = -1
		mapa.size = self.size
		mapa.isUserInteractionEnabled = false
		
		let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchRec(sender:)))
		self.view?.addGestureRecognizer(pinch)
		let rotation = UIRotationGestureRecognizer(target: self, action: #selector(rotationRec(sender:)))
		self.view?.addGestureRecognizer(rotation)
		print(mapThings.map({$0.1}))
		
	}
	
	var previousX: CGFloat = 1
	func pinchRec(sender: UIPinchGestureRecognizer){
		
		
		cam.xScale += previousX - sender.scale
		cam.yScale = cam.xScale
		
		previousX = sender.scale
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
		
		let sequence = SKAction.sequence([SKAction.scale(by: 2, duration: 0.2),
										  SKAction.scale(by: 2, duration: 0.2).reversed()])
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
			
			print(scaleFactor)
			let scaleBack = SKAction.scale(by: scaleFactor, duration: 0.2)

			node.removeAllActions()
			node.run(scaleBack)
			
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
	
	
}
