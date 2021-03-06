//
//  NewCurrencyForm.swift
//  RPGAapp
//
//  Created by Jakub on 27.06.2018.
//

import UIKit
import Former
import CoreData

class NewCurrencyForm: FormViewController {

    var currencyName: String = ""

    var currencyRate: Double = 1 

    var currencyData: [(String, Int16)] = []    

    var currency: Currency? = nil {
        
        didSet {
            guard let currency = currency else { return }

            currencyName = currency.name!
            currencyRate = currency.rate

            let subCurrencies = currency.subCurrency?.array as! [SubCurrency]
            
            for subCur in subCurrencies {
                let subName = subCur.name
                let subRate = subCur.rate
                
                let currencyDataRow = (subName!, subRate)

                currencyData.append(currencyDataRow)
            }        
        }
    }

    var createCurrencySection: SectionFormer!

    override func viewDidLoad() {

        let nameRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) {
			$0.titleLabel.text = NSLocalizedString("Name", comment: "")
			}.onTextChanged {[unowned self] in
				self.currencyName = $0
			}.configure {
				$0.text = currencyName
		}

        let globalRateRow = TextFieldRowFormer<NumberFieldCell>(instantiateType: .Nib(nibName: "NumberFieldCell")) {
			$0.titleLabel.text = NSLocalizedString("Global Rate", comment: "")
			}.onTextChanged {[unowned self] in
				self.currencyName = $0
			}.configure {
				$0.text = String(describing: currencyRate)
		}

        let globalSection = SectionFormer(rowFormers: [nameRow, globalRateRow])

        former.add(sectionFormers: [globalSection])

		if currencyData.count > 0 {
			for subCurNum in 0...currencyData.count - 1 {
				let subCur = currencyData[subCurNum]
				let subSection = createSubSection(rate: subCur.1, name: subCur.0, number: subCurNum)

				former.add(sectionFormers: [subSection])
			} 
		}
		let addSubCurrencyRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell"))
			.configure {
				$0.text = NSLocalizedString("Add new SubCurrency", comment: "")
			}.onSelected {_ in
				self.addNewSubCurrencySection()
        }

		let removeSubCurrencyRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell")) {
				$0.centerTextLabel.textColor = .red
			}.configure {
				$0.text = NSLocalizedString("Remove SubCurrency", comment: "")
			}.onSelected {[unowned self] _ in
				self.removeSubCurrency()
		}
	
        let createSubCurrencySection = SectionFormer(rowFormers: [addSubCurrencyRow, removeSubCurrencyRow])

        former.add(sectionFormers: [createSubCurrencySection])

        let createRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell"))
			.configure {
				if currency == nil {
					$0.text = NSLocalizedString("Create new currency", comment: "")
				} else {
					$0.text = NSLocalizedString("Edit currency", comment: "")
				}
			}.onSelected {_ in
				self.createCurrency()
		}
	
        let dismissRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell")) {
			$0.centerTextLabel.textColor = .red
			}.configure {
				$0.text	= NSLocalizedString("Dismiss changes", comment: "")
			}.onSelected {_ in
				self.dismissView()
		} 

        createCurrencySection = SectionFormer(rowFormers: [createRow, dismissRow])

        former.add(sectionFormers: [createCurrencySection])

        super.viewDidLoad()
    }

	func addNewSubCurrencySection() {
		let defaultData = ("", Int16(1))
		currencyData.append(defaultData)
	
		let newSubSection = createSubSection(name: "", number: currencyData.count - 1)
		former.insert(sectionFormer: newSubSection, above: createCurrencySection)
		former.reload()
	}

	func removeSubCurrency() {
		guard currencyData.count > 0 else { return }
		let lastSubCurrency = currencyData.count
		currencyData.removeLast()
		former.remove(section: lastSubCurrency)
		former.reload()
	}

    func createSubSection(rate: Int16 = 1, name: String, number: Int) -> SectionFormer {
        let nameRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) {
			$0.titleLabel.text = NSLocalizedString("Name", comment: "")
			}.onTextChanged {[unowned self] in
				self.currencyData[number].0 = $0
			}.configure {
				$0.text = self.self.currencyData[number].0
		}

        let ratioRow = TextFieldRowFormer<NumberFieldCell>(instantiateType: .Nib(nibName: "NumberFieldCell")) {
			$0.titleLabel.text = NSLocalizedString("Rate", comment: "")
			$0.allowFloatingPoint = false
			}.onTextChanged {
				guard let num = Int16($0) else { return }
				self.currencyData[number].1 = num
			}.configure {
				$0.text = String(self.currencyData[number].1)
		}

        let section = SectionFormer(rowFormers: [nameRow, ratioRow])

        return section
    }

    func createCurrency() {
        guard currencyName != "", currencyRate != 0, currencyData.count != 0 else {
			shakeView(self.view)
			return
		}

		let context = CoreDataStack.managedObjectContext
	
        var newCurrency: Currency!

        if let editedCurrency = currency {
			newCurrency = editedCurrency
            newCurrency.name = currencyName
            newCurrency.rate = currencyRate

            let subCurrencies = currency?.subCurrency?.array as! [SubCurrency]

			let numOfSubCurennciesToDelete = subCurrencies.count - currencyData.count

            for curDataNum in 0...currencyData.count - 1 {
                let subCur: SubCurrency!
                let subData = currencyData[curDataNum]

                if subCurrencies.count - 1 > curDataNum {
                    subCur = subCurrencies[curDataNum]                 
                } else {
                    subCur = NSEntityDescription.insertNewObject(forEntityName: String(describing: SubCurrency.self), into: context) as! SubCurrency
                }

				subCur.name = subData.0
				subCur.rate = subData.1

				currency?.addToSubCurrency(subCur)
            }

            if numOfSubCurennciesToDelete > 0 {
                let toDelete = subCurrencies.dropLast(numOfSubCurennciesToDelete)

                for del in toDelete {
                    context.delete(del)
                }
            }
        } else {
            newCurrency = Currency.create(name: currencyName, rate: currencyRate, subList: currencyData)
        }
        
        CoreDataStack.saveContext()

        NotificationCenter.default.post(name: .currencyCreated, object: nil)

        dismissView()


		let action = CurrencyCreated(currency: newCurrency)
		PackageService.pack.send(action: action)
    }

    func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
