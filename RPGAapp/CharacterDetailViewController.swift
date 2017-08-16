//
//  CharacterDetailViewController.swift
//  RPGAapp
//
//  Created by Jakub on 08.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import UIKit

class CharacterDetailViewController: UIViewController {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    var currentCharacter: character?
    
    func configureView() {
        // Update the user interface for the detail item.
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

struct character {
    var name : String
    var health: Int
    var race : String?
    var profesion : String?
    var abilites : [String]?
    var abilitesNames : [String]?
    var items: [Int]?
}




/*func generateRandomCharacter() -> character{
    let profTable = loadStringTableFromDataAsset(Data: "Profesions")
    let nameTable = loadStringTableFromDataAsset(Data: "Names")
    let raceTable = loadStringTableFromDataAsset(Data: "Races")
    let r2pTable = tableForWRE(table: loadStringTableFromDataAsset(Data: "R2P"))
    let race = myRand(4)
    let raceName = raceTable[race].first
    
    let name = nameTable [myRand(20)][race]
    
    let profesion = weightedRandomElement(items: r2pTable[race])
    
    let profesionName = profTable[profesion].first
    
    //let profesionName = r2pTable
    
    
    let abilites = Array(profTable[profesion].dropFirst())
    let abilitesNames = Array(profTable[0].dropFirst())
    
    
    
    let newChar = character(name: name,race: raceName, profesion: profesionName,abilites : abilites, abilitesNames: abilitesNames)
    
    return newChar
}*/
