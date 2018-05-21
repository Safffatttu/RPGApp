//
//  MapHelperFunctions.swift
//  RPGAapp
//
//  Created by Jakub on 16.05.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import SpriteKit

extension SKSpriteNode{
	convenience init(entity: MapEntity, parent: SKScene,size: Int = 30) {
		
		self.init(color: .black, size: CGSize(width: size, height: size))
		
		parent.addChild(self)
		self.position = CGPoint(x: entity.x, y: entity.y)

		if let name = entity.character?.name{
			let label = SKLabelNode(text: name)
			self.addChild(label)
			label.position.y = 20
		}
	}
}
