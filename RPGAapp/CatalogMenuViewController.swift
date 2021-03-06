//
//  KatalogMenuViewController.swift
//  RPGAapp
//
//  Created by Jakub on 09.08.2017.
//

import Foundation
import UIKit
import CoreData

class CatalogeMenu: UIViewController {

	var list: [(String, [(String, Int)])] = CatalogeDataSource.source.menuItems
	var model: CatalogeModel = CatalogeDataSource.source.model

    @IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!

	var showModel: Bool = false

    override func viewWillAppear(_ animated: Bool) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(showModelView))
        NotificationCenter.default.addObserver(self, selector: #selector(dismissKeyboard), name: .dismissKeyboard, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: .reloadCataloge, object: nil)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        super.viewWillAppear(animated)
    }

	@objc
    func reloadTableView() {
		list = CatalogeDataSource.source.menuItems
		tableView.reloadData()
	}

    @objc
    func dismissKeyboard() {
        searchBar.endEditing(true)
    }

    @objc
    func showModelView() {
        showModel = !showModel
		tableView.reloadData()
    }

}

extension CatalogeMenu: UITableViewDataSource, UITableViewDelegate {

	func numberOfSections(in tableView: UITableView) -> Int {
		if showModel {
			return model.sectionCount
		}

		return list.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if showModel {
			return model[section].count
		} else {
			return list[section].1.count
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if showModel {
			let modelItem = model[indexPath.section][indexPath.row]

			let cell = tableView.dequeueReusableCell(withIdentifier: modelItem.cellName)

			if let filterItem = modelItem as? CatalogeFilterItem, let filterCell = cell as? CatalogeFilterCell {
				filterCell.setup(using: filterItem)
				cell?.selectionStyle = .none
			} else {
				cell?.textLabel?.text = modelItem.name
				cell?.detailTextLabel?.text = ""
				cell?.accessoryType = modelItem.selected ? .checkmark: .none
			}

			return cell!
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "catalogeMenuCell")
			let cellSubCategory = list[indexPath.section].1[indexPath.row]

			cell?.textLabel?.text = cellSubCategory.0.capitalized
			cell?.detailTextLabel?.text = String(cellSubCategory.1)
			cell?.accessoryType = .none

			return cell!
		}
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if showModel {
			return model[section].name
		} else {
			return list[section].0
		}
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if showModel {
			model[indexPath.section].select(index: indexPath.row)

			tableView.reloadData()
		} else {
			NotificationCenter.default.post(name: .goToSectionCataloge, object: indexPath)
		}
	}

	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		if showModel {
			model[indexPath.section].select(index: indexPath.row)
			tableView.reloadData()
		}
	}
}

extension CatalogeMenu: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		let searchFieldIsFull = searchText.replacingOccurrences(of: " ", with: "").count > 0

		NotificationCenter.default.post(name: .searchCataloge, object: searchText)

		if searchFieldIsFull && !showModel {
			showModel = true

			tableView.reloadData()
		} else {
			showModel = false

			tableView.reloadData()
		}
    }
}

extension Notification.Name {
    static let goToSectionCataloge = Notification.Name("goToSectionCataloge")
    static let searchCataloge = Notification.Name("searchCataloge")
    static let dismissKeyboard = Notification.Name("dismissKeyboard")
}
