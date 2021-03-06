//
//  RandomItemMenuViewController.swift
//  RPGAapp
//
//  Created by Jakub on 12.08.2017.
//

import Foundation
import UIKit
import CoreData

class RandomItemMenu: UITableViewController {

    var drawSettings: [DrawSetting] = Load.drawSettings()
    var subCategories: [SubCategory] = Load.subCategories()
    var categories: [Category] = Load.categories()

    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDrawSetting(_:)))

        NotificationCenter.default.addObserver(self, selector: #selector(reloadDrawSettings), name: .reloadDrawSettings, object: nil)

        self.tableView.accessibilityIdentifier = "randomItemMenu"
        super.viewDidLoad()
    }

    @objc
    func reloadDrawSettings() {
        drawSettings = Load.drawSettings()

        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if drawSettings.count > 0 {
            return categories.count + 2
        } else {
            return categories.count + 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if drawSettings.count > 0 {
            if section == 0 {
                return drawSettings.count
            } else if section == 1 {
                return 1
            }
            return (categories[section - 2].subCategories?.count)! + 1
        } else {
            if section == 0 {
                return 1
            }
            return (categories[section - 1].subCategories?.count)! + 1
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if drawSettings.count > 0 {
            if section == 0 {
                return NSLocalizedString("Custom draw presets", comment: "")
            } else if section == 1 {
                return NSLocalizedString("All items", comment: "")
            } else {
                return categories[section - 2].name
            }
        } else if section == 0 {
            return NSLocalizedString("All items", comment: "")
        } else {
            return categories[section - 1].name
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.section == 0 && drawSettings.count > 0 {
            return CGFloat((drawSettings[indexPath.row].subSettings?.count)! * 30 + 25)
        } else {
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section: Int
        if drawSettings.count > 0 {
            section = indexPath.section - 2
        } else {
            section = indexPath.section - 1
        }

        if indexPath.section == 0 && drawSettings.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DrawSettingCell") as! DrawSettingCell
            cell.nameLabel?.text = drawSettings[indexPath.row].name
            cell.drawSetting = drawSettings[indexPath.row]
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "RandomItemCell")
        let cellName: String

        if section == -1 {
            cell?.textLabel?.text = NSLocalizedString("All items", comment: "")
            return cell!
        }

        if indexPath.row == 0 {
            cellName = NSLocalizedString("Whole category", comment: "") + " " + categories[section].name!
            cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: (cell?.textLabel?.font.pointSize)!)
        } else {
            cell?.textLabel?.font = UIFont.systemFont(ofSize: (cell?.textLabel?.font.pointSize)!)
            cellName = (categories[section].subCategories?.sortedArray(using: [.sortSubCategoryByName])[indexPath.row - 1] as! SubCategory).name!
        }

        cell?.textLabel?.text = cellName
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		var setting: Any?

		let section: Int

		if self.drawSettings.count > 0 {
			section = indexPath.section - 2
		} else {
			section = indexPath.section - 1
		}

		if indexPath.section == 0 && drawSettings.count > 0 {
			setting = drawSettings[indexPath.row]
		} else if indexPath.row == 0 && section != -1 {
			setting = categories[section]
		} else if section != -1 {
			setting = categories[section].subCategories?.sortedArray(using: [.sortSubCategoryByName])[indexPath.row - 1] as? SubCategory
		}

		ItemDrawManager.drawManager.drawItems(using: setting)
		NotificationCenter.default.post(name: .reloadRandomItemTable, object: nil)
	}

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 && drawSettings.count > 0
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, _)   in
            let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingEditor") as! UINavigationController
            let editController = navController.viewControllers.first as! EditDrawSetting

            navController.modalPresentationStyle = .pageSheet

            editController.setting = self.drawSettings[indexPath.row]
            editController.editingMode = true

            self.present(navController, animated: true, completion: nil)
        }
        editAction.backgroundColor = .blue
        

        let deleteAction = UIContextualAction(style: .normal, title: "Remove") {[unowned self] (_, _, _) in
            let settingToDelete = self.drawSettings[indexPath.row]

            if (ItemDrawManager.drawManager.lastDrawSetting as? DrawSetting) == settingToDelete {
                ItemDrawManager.drawManager.lastDrawSetting = nil
            }

            self.drawSettings.remove(at: indexPath.row)

            let context = CoreDataStack.managedObjectContext
            context.delete(settingToDelete)

            CoreDataStack.saveContext()

            if self.drawSettings.count == 0 {
                let index = IndexSet(integer: 0)
                tableView.deleteSections(index, with: .automatic)
            } else {
                let index = IndexPath(row: indexPath.row, section: 0)
                tableView.deleteRows(at: [index], with: .automatic)
            }
        }

        deleteAction.backgroundColor = .red

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    @objc
    func addDrawSetting(_ sender: UIBarButtonItem) {
        let addDrawSettingControler = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingEditor")

        addDrawSettingControler.modalPresentationStyle = .pageSheet

        self.present(addDrawSettingControler, animated: true, completion: nil)
    }
}

extension Notification.Name {
    static let reloadRandomItemTable = Notification.Name("reloadRandomItemTable")
    static let reloadDrawSettings = Notification.Name("reloadDrawSettings")
}
