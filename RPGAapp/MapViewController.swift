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

class MapViewController: UIViewController {
	
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
	}
	
}
