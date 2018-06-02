//
//  CatalogeDetailExpandedCell.swift
//  RPGAapp
//
//  Created by Jakub on 02.06.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class CatalogeDetailExpandedCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate{
	
	var atributes: [ItemAtribute]!
	var atributeHandler: ItemAtributeHandler!
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!
	@IBOutlet weak var rarityLabel: UILabel!
	@IBOutlet weak var measureLabel: UILabel!
	
	@IBOutlet weak var descriptionTextView: UITextView!
	
	@IBOutlet var packageButton: UIButton!
	@IBOutlet var editButton: UIButton!
	@IBOutlet var infoButton: UIButton!
	@IBOutlet var sendButton: UIButton!
	
	@IBOutlet weak var atributeTable: UITableView!
	
	weak var cellDelegate: catalogeDetailCellDelegate?
	
	var item: Item? = nil{
		didSet{
			self.nameLabel.text = item?.name
			self.priceLabel.text = String(describing: item?.price) + "PLN"
			self.rarityLabel.text = rarityName[Int((item?.rarity)!)]
			self.measureLabel.text = item?.measure
			
			self.descriptionTextView.text = item?.item_description
			
			atributeTable.dataSource = self
			atributeTable.delegate = self
			atributeHandler = NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemAtributeHandler.self), into: CoreDataStack.managedObjectContext) as! ItemAtributeHandler
			
			let sortAtributes = NSSortDescriptor(key: #keyPath(ItemAtribute.name), ascending: true)
			atributes = item?.itemAtribute?.sortedArray(using: [sortAtributes]) as! [ItemAtribute]
			
			if atributes != nil{
				for cellNum in 0...tableView(atributeTable, numberOfRowsInSection: 0){
					let cell = atributeTable.cellForRow(at: IndexPath(row: cellNum, section: 0))
					cell?.prepareForReuse()
					cell?.setSelected(false, animated: true)
					cell?.accessoryType = .none
				}
			}
			atributeTable.reloadData()
		}
	}
	
	override func awakeFromNib() {
		
		self.sendButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
		self.sendButton.setTitle(String.fontAwesomeIcon(name: .send), for: .normal)
		
		self.infoButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
		self.infoButton.setTitle(String.fontAwesomeIcon(name: .info), for: .normal)
		
		self.editButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
		self.editButton.setTitle(String.fontAwesomeIcon(name: .edit), for: .normal)	
		
		self.packageButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
		self.packageButton.setTitle(String.fontAwesomeIcon(name: .cube), for: .normal)
	}
	
	//MARK: CatalogExpandedAtributeTable
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard item != nil else {
			return 0
		}
		if(atributes.count == 0){
			return 1
		}else{
			return atributes.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "AtributeCell")
		if atributes.count == 0{
			cell?.textLabel?.text = "Brak atrybutów"
			return cell!
		}
		cell?.textLabel?.text = atributes[indexPath.row].name
		cell?.selectionStyle = .none
		if (atributeHandler.itemAtributes?.contains(atributes[indexPath.row]))!{
			cell?.accessoryType = .checkmark
		}
		else{
			cell?.accessoryType = .none
		}
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard atributes.count != 0 else{
			return
		}
		let newAtribute = atributes[indexPath.row]
		atributeHandler.addToItemAtributes(newAtribute)
		
		let cell = tableView.cellForRow(at: indexPath)
		cell?.accessoryType = .checkmark
	}
	
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		guard atributes.count != 0 else{
			return
		}
		let atribute = atributes[indexPath.row]
		atributeHandler.removeFromItemAtributes(atribute)
		
		let cell = tableView.cellForRow(at: indexPath)
		cell?.accessoryType = .none
	}
	
	//MARK: CatalogeProtocolButtons
	
	@IBAction func addToPackageButton(_ sender: UIButton) {
		cellDelegate?.addToPackageButton(sender)
	}
	
	@IBAction func editItemButton(_ sender: UIButton) {
		cellDelegate?.editItemButton(sender)
	}
	
	@IBAction func showInfoButton(_ sender: UIButton) {
		cellDelegate?.showInfoButton(sender)
	}
	
	@IBAction func sendItemButton(_ sender: UIButton) {
		cellDelegate?.sendItemButton(sender)
	}
	
}