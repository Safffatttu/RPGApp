//
//  NewCurrencyForm.swift
//  RPGAapp
////  Created by Jakub on 27.06.2018.
//  Copyright © 2017 Jakub. All rights reserved.
//

import UIKit
import Former
import CoreData

class NewCurrencyForm: FormViewController {

    var currencyName: String = ""

    var currencyRate: Double = 1 

    var currencyData: [(String, Int16)] = []    

    var currency: Currency? = nil{
        
        didSet {
            guard let currency = currency else { return }

            currencyName = currency.name!
            currencyRate = currency.rate

            let subCurrencies = currency.subCurrency?.array as! [SubCurrency]
            
            for subCur in subCurrencies{
                let subName = subCur.name
                let subRate = subCur.rate
                
                let currencyDataRow = (subName!, subRate)

                currencyData.append(currencyDataRow)
            }        
        }
    }
	
	var createCurrencySection: SectionFormer!

    override func viewDidLoad(){

        let nameRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")){
			$0.titleLabel.text = NSLocalizedString("Name", comment: "")
			}.onTextChanged{[unowned self] in
				self.currencyName = $0
			}.configure{
				$0.text = currencyName
		}

        let globalRateRow = TextFieldRowFormer<NumberFieldCell>(instantiateType: .Nib(nibName: "NumberFieldCell")){
			$0.titleLabel.text = NSLocalizedString("Global Rate", comment: "")
			}.onTextChanged{[unowned self] in
				self.currencyName = $0
			}.configure{
				$0.text = String(describing: currencyRate)
		}

        let globalSection = SectionFormer(rowFormers: [nameRow, globalRateRow])

        former.add(sectionFormers: [globalSection])
			
		if currencyData.count > 0{
			for subCurNum in 0...currencyData.count - 1 {
				let subCur = currencyData[subCurNum]
				let subSection = createSubSection(rate: subCur.1, name: subCur.0, number: subCurNum)

				former.add(sectionFormers: [subSection])
			} 
		}
        let addSubCurrencyRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell"))
			.configure{
				$0.text = NSLocalizedString("Add new SubCurrency", comment: "")
			}.onSelected{_ in
				self.addNewSubCurrencySection()
        }

        let createSubCurrencySection = SectionFormer(rowFormers: [addSubCurrencyRow])

        former.add(sectionFormers: [createSubCurrencySection])

        let createRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell"))
			.configure{
				if currency == nil{
					$0.text = NSLocalizedString("Create new currency", comment: "")
				}else{
					$0.text = NSLocalizedString("Edit currency", comment: "")
				}
			}.onSelected{_ in
				self.createCurrency()
		}
		
        let dismissRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell")){
			$0.centerTextLabel.textColor = .red
			}.configure{
				$0.text	= NSLocalizedString("Dismiss changes", comment: "")
			}.onSelected{_ in
				self.dismissView()
		} 

        createCurrencySection = SectionFormer(rowFormers: [createRow, dismissRow])

        former.add(sectionFormers: [createCurrencySection])

        super.viewDidLoad()
    }

	func addNewSubCurrencySection(){
		let defaultData = ("", Int16(1))
		currencyData.append(defaultData)
		
		let newSubSection = createSubSection(name: "", number: currencyData.count - 1)
		former.insert(sectionFormer: newSubSection, above: createCurrencySection)
		former.reload()
	}
	
    func createSubSection(rate: Int16 = 1, name: String, number: Int) -> SectionFormer{
        let nameRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")){
			$0.titleLabel.text = NSLocalizedString("Name", comment: "")
			}.onTextChanged{[unowned self] in
				self.currencyData[number].0 = $0
			}.configure{
				$0.text = self.self.currencyData[number].0
		}

        let ratioRow = TextFieldRowFormer<NumberFieldCell>(instantiateType: .Nib(nibName: "NumberFieldCell")){
			$0.titleLabel.text = NSLocalizedString("Rate", comment: "")
			$0.allowFloatingPoint = false
			}.onTextChanged{
				self.currencyData[number].1 = Int16($0)!

			}.configure{
				$0.text = self.self.currencyData[number].0

		}

        let section = SectionFormer(rowFormers: [nameRow, ratioRow])

        return section
    }

    func createCurrency(){
        guard currencyName != "", currencyRate != 0, currencyData.count != 0 else {
			shakeView(self.view)
			return
		}

		let context = CoreDataStack.managedObjectContext
		
        var newCurrency: Currency!

        if let newCurrency = currency{

            newCurrency.name = currencyName
            newCurrency.rate = currencyRate

            let subCurrencies = currency?.subCurrency?.array as! [SubCurrency]

            for curDataNum in 0...currencyData.count - 1{
                let subCur: SubCurrency!
                let subData = currencyData[curDataNum]

                if subCurrencies.count - 1 > curDataNum{
                    subCur = subCurrencies[curDataNum]                 
                }else{
                    subCur = NSEntityDescription.insertNewObject(forEntityName: String(describing: SubCurrency.self), into: context) as! SubCurrency
                }
                    subCur.name = subData.0
                    subCur.rate = subData.1
            }

            let numOfSubCurennciesToDelete = subCurrencies.count - currencyData.count

            if numOfSubCurennciesToDelete > 0{
                let toDelete = subCurrencies.dropLast(3)

                for del in toDelete{
                    context.delete(del)
                }
            }


        }else{
            newCurrency = createCurrencyUsing(name: currencyName, rate: currencyRate, subList: currencyData)
        }

        CoreDataStack.saveContext()

        NotificationCenter.default.post(name: .currencyCreated, object: nil)

        dismissView()


		let action = CurrencyCreated(currency: newCurrency)
		PackageService.pack.send(action: action)
    }

    func dismissView(){
        dismiss(animated: true, completion: nil)
    }

}
