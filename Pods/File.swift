/*func preloadData () {
    // Retrieve data from the source file
    if let contentsOfURL = NSBundle.mainBundle().URLForResource("menudata", withExtension: "csv") {
        
        // Remove all the menu items before preloading
        removeData()
        
        var error:NSError?
        if let items = parseCSV(contentsOfURL, encoding: NSUTF8StringEncoding, error: &error) {
            // Preload the menu items
            if let managedObjectContext = self.managedObjectContext {
                for item in items {
                    let menuItem = NSEntityDescription.insertNewObjectForEntityForName("MenuItem", inManagedObjectContext: managedObjectContext) as! MenuItem
                    menuItem.name = item.name
                    menuItem.detail = item.detail
                    menuItem.price = (item.price as NSString).doubleValue
                    
                    if managedObjectContext.save(&error) != true {
                        println("insert error: \(error!.localizedDescription)")
                    }
                }
            }
        }
    }
}

func removeData () {
    // Remove the existing items
    if let managedObjectContext = self.managedObjectContext {
        let fetchRequest = NSFetchRequest(entityName: "MenuItem")
        var e: NSError?
        let menuItems = managedObjectContext.executeFetchRequest(fetchRequest, error: &e) as! [MenuItem]
        
        if e != nil {
            println("Failed to retrieve record: \(e!.localizedDescription)")
            
        } else {
            
            for menuItem in menuItems {
                managedObjectContext.deleteObject(menuItem)
            }
        }
    }
}
*/
/*let fetch =  NSFetchRequest<Item>(entityName: "Item")
 //fetch.predicate = NSPredicate(format: "category == %@", "BROŃ")
 var fetched: [Item] = []
 do{
 fetched = try CoreDataStack.managedObjectContext.fetch(fetch) as! [Item]
 }
 catch{
 print("Error")
 }
 for i in fetched{
 print(i.name! + String(i.rarity))
 }*/
