//
//  SettingsMenuViewController.swift
//  RPGAapp
//
//  Created by Jakub on 09.08.2017.
//

import Foundation
import UIKit
import CoreData
import Dwifft

protocol settingCellDelegate: class {

    func touchedSwitch(_ sender: UISwitch)

    func pressedButton(_ sender: UIButton)
}

class SettingSwitchCell: UITableViewCell {

    weak var delegate: settingCellDelegate?

    @IBAction func switchChanged(_ sender: UISwitch) {
        delegate?.touchedSwitch(sender)
    }
    @IBOutlet weak var settingLabel: UILabel!

    @IBOutlet weak var settingSwitch: UISwitch!
}

class SettingButtonCell: UITableViewCell {

    weak var delegate: settingCellDelegate?

    @IBAction func buttonPressed(_ sender: UIButton) {
        delegate?.pressedButton(sender)
    }

    @IBOutlet weak var settingLabel: UILabel!

    @IBOutlet weak var settingButton: UIButton!
}

let settingValues = ["Auto hide menu": false, "Show price": true, "Dodawaj do listy wylosowanych": false, "Schowaj menu pakietów": true, "syncSessionRemoval": false]

class SettingMenu: UITableViewController {

    let keys = Array(UserDefaults.standard.dictionaryWithValues(forKeys: settingValues.map { $0.0 }))

	var sessions: [Session] = Load.sessions()

	var currencies: [Currency] = Load.currencies()

	var visibilities: [Visibility] = Load.visibilities()

	var documenController: UIDocumentInteractionController!

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(connectedDevicesChanged), name: .connectedDevicesChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchedSessionAction(_:)), name: .switchedSession, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionDeleted(_:)), name: .sessionDeleted, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(sessionReceived), name: .sessionReceived, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(currencyCreated), name: .currencyCreated, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(visibilityCreated), name: .visibilityCreated, object: nil)

		diffCalculator = TableViewDiffCalculator(tableView: tableView, initialSectionedValues: SectionedValues(createDiffTable()))
		diffCalculator?.insertionAnimation = .fade
		diffCalculator?.deletionAnimation = .fade

		super.viewWillAppear(animated)
	}

	var diffCalculator: TableViewDiffCalculator<String, String>?

	func createDiffTable() -> [(String, [String])] {
		var settingList = keys.map { $0.key }
		settingList.insert("Sync item database", at: 0)
		let settingSection = ("Settings", settingList)

		var sessionList = sessions.compactMap { session -> String? in
			guard let id = session.id else { return nil }
			return "\(id)\(session.current)"
			}
		sessionList.insert("CreateSessions", at: 0)
		let sessionsSection = ("Sessions", sessionList)

		var currencyList = currencies.compactMap { currency -> String? in
			guard let name = currency.name else { return nil }
			guard let currentCurrency = Load.currentCurrency() else { return "false\(name)" }
			let isCurrent = (currency === currentCurrency)
			return "\(isCurrent)\(name)"
		}
		currencyList.insert("CreateCurrency", at: 0)
		let currenciesSection = ("Currencies", currencyList)

		var visibilitiesList = visibilities.compactMap { visibility -> String? in
			guard let id = visibility.id else { return nil }
			return "\(visibility.current)\(id)"
		}
		visibilitiesList.insert("CreateVisibility", at: 0)
		let visibilitySeciont = ("Visibilities", visibilitiesList)

		var sectionList = [settingSection, sessionsSection, currenciesSection, visibilitySeciont]

		if PackageService.pack.session.connectedPeers.count > 0 {
			let connectedDevices = ("Devices", PackageService.pack.session.connectedPeers.map { $0.displayName })
			sectionList.append(connectedDevices)
		}

		return sectionList
	}

	func updateDiffTable() {
		let newDiffTable = createDiffTable()
		diffCalculator?.sectionedValues = SectionedValues(newDiffTable)
	}


	@objc
    func sessionReceived() {
		sessions = Load.sessions()
		visibilities = Load.visibilities()
		updateDiffTable()
	}

	@objc
    func currencyCreated() {
		currencies = Load.currencies()
		updateDiffTable()
	}

	@objc
    func visibilityCreated() {
		visibilities = Load.visibilities()
		updateDiffTable()
	}

	@objc
    func switchedSessionAction(_ notification: Notification) {
		sessions = Load.sessions()
		visibilities = Load.visibilities()
		updateDiffTable()
	}

	func switchedSession(indexPath: IndexPath) {
		for session in sessions {
			session.current = false
		}

		let session = sessions[indexPath.row - 1]
		session.current = true

		CoreDataStack.saveContext()

		visibilities = Load.visibilities()

		sessions = Load.sessions()

		updateDiffTable()

		NotificationCenter.default.post(name: .reloadTeam, object: nil)
		NotificationCenter.default.post(name: .currencyChanged, object: nil)

		let action = SessionSwitched(session: session)
		PackageService.pack.send(action: action)
	}

	@objc
    func sessionDeleted(_ notification: Notification) {
		sessions = Load.sessions()

		updateDiffTable()
	}

	@objc
    func connectedDevicesChanged() {
		updateDiffTable()
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return PackageService.pack.session.connectedPeers.count > 0 ? 5: 4
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return UserDefaults.standard.dictionaryWithValues(forKeys: settingValues.map { $0.0 }).count + 1
		} else if section == 1 {
			return sessions.count + 1
		} else if section == 2 {
			return currencies.count + 1
		} else if section == 3 {
			return visibilities.count + 1
		} else {
			return PackageService.pack.session.connectedPeers.count
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return NSLocalizedString("Settings", comment: "")
		} else if section == 1 {
			return NSLocalizedString("Sessions", comment: "")
		} else if section == 2 {
			return NSLocalizedString("Currencies", comment: "")
		} else if section == 3 {
			return NSLocalizedString("Visibilities", comment: "")
		} else {
			return NSLocalizedString("Connected devices", comment: "")
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			if indexPath.row < settingValues.count {
				let cell = tableView.dequeueReusableCell(withIdentifier: "SettingSwitchCell") as! SettingSwitchCell
				let cellSetting = keys[indexPath.row].key
				cell.settingLabel.text = NSLocalizedString(cellSetting, comment: "")
				cell.settingSwitch.setOn(UserDefaults.standard.bool(forKey: keys[indexPath.row].key), animated: false)
				cell.delegate = self
				cell.selectionStyle = .none
				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell")

				cell?.textLabel?.text = NSLocalizedString("Sync item database", comment: "")

				cell?.selectionStyle = .none
				cell?.accessoryType = .none
				cell?.textLabel?.textColor = .black

				return cell!
			}
		} else if indexPath.section == 1 {
			if indexPath.row == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "SettingButtonCell") as! SettingButtonCell
				cell.settingLabel?.text = NSLocalizedString("New session", comment: "")
				cell.selectionStyle = .none
				let localizedAdd = NSLocalizedString("Add", comment: "")
				cell.settingButton.setTitle(localizedAdd, for: .normal)
				cell.delegate = self
				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell")
				cell?.textLabel?.text = sessions[indexPath.row - 1].name! + " " + String((sessions[indexPath.row - 1].id?.suffix(4))!)

				cell?.selectionStyle = .none
				cell?.accessoryType = .none
				cell?.textLabel?.textColor = .black

				if sessions[indexPath.row - 1].current {
					cell?.accessoryType = .checkmark
				}

				return cell!
			}
		} else if indexPath.section == 2 {
			if indexPath.row == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "SettingButtonCell") as! SettingButtonCell
				cell.settingLabel?.text = NSLocalizedString("New Currency", comment: "")
				cell.selectionStyle = .none
				let localizedCreate = NSLocalizedString("Create", comment: "")
				cell.settingButton.setTitle(localizedCreate, for: .normal)
				cell.delegate = self

				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell")
				let cellCurrency = currencies[indexPath.row - 1]
				cell?.textLabel?.text =	cellCurrency.name

				cell?.selectionStyle = .none
				cell?.accessoryType = .none
				cell?.textLabel?.textColor = .black

				if cellCurrency == Load.currentCurrency() {
					cell?.accessoryType = .checkmark
				}

				return cell!
			}
		} else if indexPath.section == 3 {
			if indexPath.row == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "SettingButtonCell") as! SettingButtonCell
				cell.settingLabel?.text = NSLocalizedString("New visibility", comment: "")
				cell.selectionStyle = .none
				let localizedCreate = NSLocalizedString("Create", comment: "")
				cell.settingButton.setTitle(localizedCreate, for: .normal)
				cell.delegate = self

				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell")
				let cellVisibility = visibilities[indexPath.row - 1]
				cell?.textLabel?.text =	cellVisibility.name

				if let color = NameGenerator.colors.first(where: { $0.0 == cellVisibility.name })?.1 {
					cell?.textLabel?.textColor = color
				}

				cell?.selectionStyle = .none
				cell?.accessoryType = .none

				if cellVisibility.current {
					cell?.accessoryType = .checkmark
				}

				return cell!
			}
		} else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell")
            cell?.textLabel?.text = PackageService.pack.session.connectedPeers[indexPath.row].displayName

			cell?.selectionStyle = .none
			cell?.accessoryType = .none
			cell?.textLabel?.textColor = .black

            return cell!
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 && indexPath.row == settingValues.count {

			let syncAction = ItemListSync()
			let requestAction = ItemListRequested()

			PackageService.pack.send(action: syncAction)
			PackageService.pack.send(action: requestAction)

		} else if indexPath.section == 1 && indexPath.row > 0 && !sessions[indexPath.row - 1].current {
			guard sessions.filter({ $0.current }).count != 0 else {
				switchedSession(indexPath: indexPath)
				return
			}

			let localizedMessage = NSLocalizedString("Do you want to change session", comment: "")
            let alert = UIAlertController(title: nil, message: localizedMessage, preferredStyle: .alert)

			let localizedYes = NSLocalizedString("Yes", comment: "")
            let alertYes = UIAlertAction(title: localizedYes, style: .destructive, handler: {(_) in
                self.switchedSession(indexPath: indexPath)
            })

			let localizedNo = NSLocalizedString("No", comment: "")
            let alertNo = UIAlertAction(title: localizedNo, style: .cancel, handler: nil)

            alert.addAction(alertYes)
            alert.addAction(alertNo)

            present(alert, animated: true, completion: nil)
		} else if indexPath.section == 2 {
			if indexPath.row == 0 {
				createCurrency()
			} else {
				let session = Load.currentSession()
				sessions = Load.sessions()
				visibilities = Load.visibilities()
				session.currency = currencies[indexPath.row - 1]

				CoreDataStack.saveContext()

				updateDiffTable()

				NotificationCenter.default.post(name: .currencyChanged, object: nil)
			}
		} else if indexPath.section == 3 {
			if indexPath.row != 0 {
				var rowsToReload = [indexPath]

				let previousVisibilityIndex = visibilities.firstIndex(where: { $0.current })

				if let previousVisibilityIndex = previousVisibilityIndex {

					let previousRow = IndexPath(row: previousVisibilityIndex + 1, section: 3)

					if previousRow == indexPath {
						visibilities[previousVisibilityIndex].current = !visibilities[previousVisibilityIndex].current
					} else {
						visibilities[previousVisibilityIndex].current = false
						rowsToReload.append(previousRow)
					}
				}

				if rowsToReload.count == 2 || previousVisibilityIndex == nil {
					visibilities[indexPath.row - 1].current = true
				}

				CoreDataStack.saveContext()

				updateDiffTable()

				NotificationCenter.default.post(name: .reloadTeam, object: nil)
			}
		}
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return (indexPath.section == 1 && indexPath.row != 0)
			|| (indexPath.section == 2 && indexPath.row != 0)
			|| (indexPath.section == 3 && indexPath.row != 0)
			||  indexPath.section == 4
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		var actions: [UIContextualAction] = []
		let localizedYes = NSLocalizedString("Yes", comment: "")
		let localizedNo = NSLocalizedString("No", comment: "")
		let localizedRemove = NSLocalizedString("Remove", comment: "")

		if indexPath.section == 1 {
			actions = []

			let localizedDelete = NSLocalizedString("Delete", comment: "")
			let removeSession = UIContextualAction(style: .destructive, title: localizedDelete, handler: { (_, _, _) in

				let localizedMessage = NSLocalizedString("Do you want to delete this session?", comment: "")
				let alert = UIAlertController(title: nil, message: localizedMessage, preferredStyle: .alert)

				let alertYes = UIAlertAction(title: localizedYes, style: .destructive, handler: { (_) -> Void in

					let context = CoreDataStack.managedObjectContext
					let session = self.sessions[indexPath.row - 1]
					let sessionId = session.id
					self.sessions.remove(at: indexPath.row - 1)

					context.delete(session)
					CoreDataStack.saveContext()

					self.visibilities = Load.visibilities()

					self.updateDiffTable()

					NotificationCenter.default.post(name: .reloadTeam, object: nil)
					NotificationCenter.default.post(name: .currencyChanged, object: nil)

					let action = SessionDeleted(sessionId: sessionId!)
					PackageService.pack.send(action: action)
				})

				let alertNo = UIAlertAction(title: localizedNo, style: .cancel, handler: nil)

				alert.addAction(alertYes)
				alert.addAction(alertNo)

				self.present(alert, animated: true, completion: nil)
			})

			actions.append(removeSession)

			let localizedSendTitle = NSLocalizedString("Send", comment: "")

			let sendSession = UIContextualAction(style: .normal, title: localizedSendTitle, handler: { (_, _, _) in

				let session = self.sessions[indexPath.row - 1]

				let action = SessionReceived(session: session)
				PackageService.pack.send(action: action)

				tableView.setEditing(false, animated: true)

				let localizedSendSessionString = NSLocalizedString("Send session", comment: "")
				whisper(messege: localizedSendSessionString)
			})

			actions.append(sendSession)

			let localizedSharedTitle = NSLocalizedString("Share", comment: "")
			let shareSession = UIContextualAction(style: .normal, title: localizedSharedTitle, handler: { (_, _, _) in
				guard self.sessions.count > indexPath.row - 1 && indexPath.row - 1 >= 0  else { return }

				let dict = packSessionForMessage(self.sessions[indexPath.row - 1])
				let url = save(dictionary: dict)

				self.documenController = UIDocumentInteractionController(url: url)

				let touchPoint = tableView.rectForRow(at: indexPath)
				self.documenController.presentOptionsMenu(from: touchPoint, in: tableView, animated: true)
			})

			shareSession.backgroundColor = UIColor.darkGray

			actions.append(shareSession)

		} else if indexPath.section == 2 {
			let deleteCurrency = UIContextualAction(style: .destructive, title: localizedRemove, handler: { (_, _, _) in

				let currencyToDelete = self.currencies[indexPath.row - 1]

				self.currencies.remove(at: indexPath.row - 1)

				let context = CoreDataStack.managedObjectContext
				context.delete(currencyToDelete)

				CoreDataStack.saveContext()

				self.updateDiffTable()
			})
			let localizedEdit = NSLocalizedString("Edit", comment: "")

			let editCurrency = UIContextualAction(style: .normal, title: localizedEdit, handler: { (_, _, _) in
				let currency = self.currencies[indexPath.row - 1]

				let currencyForm = NewCurrencyForm()
				currencyForm.modalPresentationStyle = .formSheet

				currencyForm.currency = currency

				self.present(currencyForm, animated: true, completion: nil)
			})

			actions = [deleteCurrency, editCurrency]
		} else if indexPath.section == 3 {
			let deleteVisibility = UIContextualAction(style: .destructive, title: localizedRemove, handler: {  (_, _, _) in

				let visibilityToDelete = self.visibilities[indexPath.row - 1]
				let visibilityId = visibilityToDelete.id

				self.visibilities.remove(at: indexPath.row - 1)

				let context = CoreDataStack.managedObjectContext
				context.delete(visibilityToDelete)

				CoreDataStack.saveContext()

				self.updateDiffTable()

				let action = VisibilityRemoved(visibilityId: visibilityId!)
				PackageService.pack.send(action: action)
			})

			actions = [deleteVisibility]
		} else if indexPath.section == 4 {
			actions = []
			let removePeer = UIContextualAction(style: .destructive, title: localizedRemove, handler: { (_, _, _) in

				let peer = PackageService.pack.session.connectedPeers[indexPath.row]
				let action = DisconnectPeer(peer: peer.displayName)

				PackageService.pack.send(action: action)
				PackageService.pack.session.cancelConnectPeer(peer)
			})
			actions.append(removePeer)
		}

		return UISwipeActionsConfiguration(actions: actions)
	}

}

extension SettingMenu: settingCellDelegate {

    func touchedSwitch(_ sender: UISwitch) {
        if let indexPath = getCurrentCellIndexPath(sender, tableView: self.tableView) {
            UserDefaults.standard.set(sender.isOn, forKey: keys[indexPath.row].key)
            if keys[indexPath.row].key == "Show price" {
                NotificationCenter.default.post(name: .reloadRandomItemTable, object: nil)
            }
        }
    }

    func pressedButton(_ sender: UIButton) {
		guard let index = getCurrentCellIndexPath(sender, tableView: self.tableView) else { return } 

		if index.section == 1 {
            Session.create()
		} else if index.section == 2 {
			createCurrency()
		} else if index.section == 3 {
            Visibility.createVisibility()
            visibilities = Load.visibilities()
		}
        sessions = Load.sessions()
        updateDiffTable()
    }

	func createCurrency() {
		let currencyForm = NewCurrencyForm()

		currencyForm.modalPresentationStyle = .formSheet

		present(currencyForm, animated: true)

	}

}

extension Notification.Name {
    static let switchedSession = Notification.Name("switchedSession")
    static let sessionDeleted = Notification.Name("sessionDeleted")
	static let sessionReceived = Notification.Name("sessionReceived")
	static let currencyCreated = Notification.Name("currencyCreated")
	static let currencyChanged = Notification.Name("currencyChanged")
	static let visibilityCreated = Notification.Name("visibilityCreated")
}
