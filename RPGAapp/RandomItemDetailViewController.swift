//
//  RandomItemDetailViewController.swift
//  RPGAapp
//
//  Created by Jakub on 11.08.2017.
//

import Foundation
import UIKit
import CoreData
import Dwifft

class RandomItemDetailView: UIViewController, UITableViewDataSource, UITableViewDelegate, randomItemCellDelegate, UIPopoverPresentationControllerDelegate {

    let iconSize: CGFloat = 20

    @IBOutlet weak var tableView: UITableView!

    var diffCalculator: SingleSectionTableViewDiffCalculator<Val>?

    struct Val: Equatable {
        var name: String
        var count: Int64

        static func == (lhs: RandomItemDetailView.Val, rhs: RandomItemDetailView.Val) -> Bool {
            return lhs.count == rhs.count && lhs.name == rhs.name
        }
    }

    var diffTable: [Val] = []

    func setDiffTable() {
        diffTable = []

		if ItemDrawManager.randomlySelected.count == 0 {
			diffTable = [Val(name: "", count: 0)]
		} else {
			for han in ItemDrawManager.randomlySelected {
				guard let name = han.item?.name else { continue }
				let newVal = Val(name: name, count: han.count)
				diffTable.append(newVal)
			}
		}
    }

    override func viewDidLoad() {
        setDiffTable()
        self.diffCalculator = SingleSectionTableViewDiffCalculator(tableView: tableView, initialRows: diffTable, sectionIndex: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.accessibilityIdentifier = "selectedTable"
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: .reloadRandomItemTable, object: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.diffCalculator?.rows.count ?? 0
    }

    @objc
    func reloadTableData() {
        setDiffTable()
        diffCalculator?.rows = diffTable
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RandomItemCell") as! RandomItemCell

        if ItemDrawManager.randomlySelected.count > 0 {
            let cellItem = ItemDrawManager.randomlySelected[indexPath.row]

			cell.itemHandler = cellItem
			cell.cellDelegate = self

			cell.sendButton.isHidden = false
			cell.infoButton.isHidden = false
			cell.redrawButton.isHidden = false
			cell.packageButton.isHidden = false
        } else {
            cell.nameLabel?.text = NSLocalizedString("Have not draw items yet", comment: "")
            cell.priceLabel?.text = ""

            cell.sendButton.isHidden = true
            cell.infoButton.isHidden = true
            cell.redrawButton.isHidden = true
            cell.packageButton.isHidden = true
        }

		cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contex = CoreDataStack.managedObjectContext
            let handlerToRemove = ItemDrawManager.randomlySelected[indexPath.row]
            ItemDrawManager.randomlySelected.remove(at: indexPath.row)

			reloadTableData()

            contex.delete(handlerToRemove)
            CoreDataStack.saveContext()
        }
    }

    func addToPackage(_ sender: UIButton) {
        let indexPath = getCurrentCellIndexPath(sender, tableView: tableView)

        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addToPackage")

        popController.modalPresentationStyle = .popover

        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender

        (popController as! AddToPackage).itemToAdd = ItemDrawManager.randomlySelected[(indexPath?.row)!]

        self.present(popController, animated: true, completion: nil)
    }

    func reDrawItem(_ sender: UIButton) {
		guard let indexPath = getCurrentCellIndexPath(sender, tableView: tableView) else { return }

		let handlerToReDraw = ItemDrawManager.randomlySelected[indexPath.row]

		ItemDrawManager.drawManager.reDrawItem(handler: handlerToReDraw)

		reloadTableData()
    }

    func showInfo(_ sender: UIButton) {
        let indexPath = getCurrentCellIndexPath(sender, tableView: tableView)
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "showInfoPop")

        popController.modalPresentationStyle = .popover

        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        (popController as! ShowItemInfoPopover).item = ItemDrawManager.randomlySelected[(indexPath?.row)!].item

        self.present(popController, animated: true, completion: nil)
    }

    func sendItem(_ sender: UIButton) {
        let indexPath = getCurrentCellIndexPath(sender, tableView: tableView)
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sendPop")

        popController.modalPresentationStyle = UIModalPresentationStyle.popover

        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        (popController as! SendPopover).itemHandler = ItemDrawManager.randomlySelected[(indexPath?.row)!]

        self.present(popController, animated: true, completion: nil)
    }

    @IBAction func reDrawAllItems(_ sender: UIButton) {
        ItemDrawManager.drawManager.reDrawAllItems()
		reloadTableData()
    }

    @IBAction func addAllToPackage(_ sender: UIView) {
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addToPackage")

        popController.modalPresentationStyle = .popover

        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender

        (popController as! AddToPackage).itemsToAdd = ItemDrawManager.randomlySelected

        self.present(popController, animated: true, completion: nil)
    }


    @IBAction func sendAll(_ sender: UIButton) {
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sendPop")

        popController.modalPresentationStyle = UIModalPresentationStyle.popover

        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        (popController as! SendPopover).itemHandlers = ItemDrawManager.randomlySelected

        self.present(popController, animated: true, completion: nil)
    }
}
