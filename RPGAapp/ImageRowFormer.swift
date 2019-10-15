//
//  ImageRowFormer.swift
//  RPGAapp
//
//  Created by Jakub on 25.06.2018.
//

import Foundation
import UIKit
import Former

public protocol ImageFormableRow: FormableRow {
	
	func formImageView() -> UIImageView?
	
}

final class ImageRowFormer<T: UITableViewCell>: BaseRowFormer<T>, Formable where T: ImageFormableRow {
	
	public var image: UIImage?
	
	public required init(instantiateType: Former.InstantiateType = .Class, cellSetup: ((T) -> Void)? = nil) {
		super.init(instantiateType: instantiateType, cellSetup: cellSetup)
	}
	
	override func initialized() {
		super.initialized()
	}
	
	public override func update() {
		
		if let image = image{
			let imageView = cell.formImageView()
			
			imageView?.image = image
			
			rowHeight = 400
			
			super.update()
			
		}else{
			super.update()
		}
		
	}
	
}

class FormImageCell: FormCell, ImageFormableRow{
	
	@IBOutlet weak var _imageView: UIImageView!
	
	public func formImageView() -> UIImageView? {
		_imageView.contentMode = .scaleAspectFit
		return _imageView
	}
	
}
