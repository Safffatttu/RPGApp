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
	convenience init(entity: MapEntity, parent: SKScene) {
		
		self.init(color: .black, size: CGSize(width: 10, height: 10))
		
		parent.addChild(self)
		self.position = CGPoint(x: entity.x, y: entity.y)

	}
}
