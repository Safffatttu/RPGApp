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
	
	var map: Map!{
		didSet{
			let things = map.entities?.allObjects as! [MapEntity]
			
			var newMapEntities: [(MapEntity,SKSpriteNode)] = []
			
			for t in things{
				let newSprite = SKSpriteNode(entity: t, parent: self)
				
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
		
		let n = SKSpriteNode(imageNamed: "mapa")
		self.addChild(n)
		print(self.size)
		n.zPosition = -1
		n.size = self.size
		
		
		let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchRec(sender:)))
		self.view?.addGestureRecognizer(pinch)
		
	}
	
	var previousX: CGFloat = 1
	func pinchRec(sender: UIPinchGestureRecognizer){
		
		
		cam.xScale += previousX - sender.scale
		cam.yScale = cam.xScale
		
		previousX = sender.scale
	}
	
	
	func touchDown(atPoint pos : CGPoint) {
		
	}
	
	func touchMoved(toPoint pos : CGPoint) {
		
	}
	
	func touchUp(atPoint pos : CGPoint) {
		
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchDown(atPoint: t.location(in: self)) }
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else {
			return
		}
		
		let location = touch.location(in: self)
		let previousLocation = touch.previousLocation(in: self)
		
		camera?.position.x += previousLocation.x - location.x
		camera?.position.y += previousLocation.y - location.y
	
		for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchUp(atPoint: t.location(in: self)) }
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchUp(atPoint: t.location(in: self)) }
	}
	
	
	override func update(_ currentTime: TimeInterval) {
		// Called before each frame is rendered
	}
	
	
}
