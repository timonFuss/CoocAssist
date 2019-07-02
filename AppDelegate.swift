//
//  AppDelegate.swift
//  Flavr
//
//  Created by Timon Fuß on 09.02.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import UIKit
import CoreData

extension Ingredient {
    func configured(image _image: String,
                    name _name: String,
                    measurement _measurement: Float,
                    measurementUnit _measurementUnit: String,
                    atHome _atHome: Bool) -> Self {
        image =  _image
        name = _name
        measurement = _measurement
        measurementUnit = _measurementUnit
        atHome =  _atHome
        return self
    }
}

extension Instruction {
    func configured(context _context: String,
                    image _image: String,
                    instruction _instruction: String,
                    posNr _posNr: Int16) -> Self {
        context = _context
        image =  _image
        instruction = _instruction
        posNr = _posNr
        return self
    }
    
}

extension RecipeTimer {
    func configured(time _time: Float,
                    finishMessage _finishMessage: String,
                    identifier _identifier: String,
                    amountOfInstr _amountOfInstr: Int16) -> Self {
        time =  _time
        finishMessage =  _finishMessage
        identifier =  _identifier
        amountOfInstr =  _amountOfInstr
        return self
    }
    
}

extension RecipeNote {
    func configured(finishMessage _finishMessage: String,
                    identifier _identifier: String) -> Self {
        finishMessage =  _finishMessage
        identifier =  _identifier
        return self
    }
    
}

enum ReadDataExceptions: Error {
    case moreThatOneRecipeCameBack
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func writeData() throws{
        
        let context = persistentContainer.viewContext
        
        let recipe = Recipe(context: context)
        recipe.name = "Spaghetti Napoli"
        recipe.recipeImage = "pasta_bolognese"
        recipe.category = "Beef"
        recipe.cookingTime = 20
        
        //Add Ingredients to Recipe
        recipe.addToIngredients(NSSet(array: [
            Ingredient(context: context).configured(image: "tomato", name: "Tomaten", measurement: 4, measurementUnit: "", atHome: false),
            Ingredient(context: context).configured(image: "noodle", name: "Spaghetti", measurement: 200, measurementUnit: "g", atHome: true),
            Ingredient(context: context).configured(image: "blackpepper", name: "Pfeffer", measurement: 2, measurementUnit: "EL", atHome: false),
            Ingredient(context: context).configured(image: "salt", name: "Salz", measurement: 1, measurementUnit: "Prise", atHome: true),
            Ingredient(context: context).configured(image: "basil", name: "Basilikum", measurement: 8, measurementUnit: "Blätter", atHome: false),
            Ingredient(context: context).configured(image: "onion", name: "Zwiebeln", measurement: 1, measurementUnit: "", atHome: true),
            Ingredient(context: context).configured(image: "tomatopaste", name: "Tomatenmark", measurement: 2, measurementUnit: "EL", atHome: false),
            Ingredient(context: context).configured(image: "garlic", name: "Knoblauch", measurement: 1, measurementUnit: "Zehe", atHome: false)
            ]))
        
        //Create Instructions and add their Ingredients
        let instr1 = Instruction(context: context).configured(context: "cooking",image: "", instruction: "Setze kochendes Wasser auf", posNr: 1)
        instr1.note = RecipeNote(context: context).configured(finishMessage: "Eine Prise Salz verringert die Kochzeit.", identifier: "SalzNotiz")
        
        let instr2 = Instruction(context: context).configured(context: "cutting",image: "", instruction: "Erhitze eine Pfanne und gebe {Anzahl} kleingewürfelte {Zutat} hinzu", posNr: 2)
        instr2.addToIngredients(NSSet(array: [
            Ingredient(context: context).configured(image: "onion", name: "Zwiebel", measurement: 1, measurementUnit: "", atHome: true)
            ]))
        
        let instr3 = Instruction(context: context).configured(context: "cooking",image: "", instruction: "Füge die Nudeln in das kochende Wasser ein", posNr: 3)
        instr3.addToIngredients(NSSet(array: [
            Ingredient(context: context).configured(image: "noodle", name: "Spaghetti", measurement: 200, measurementUnit: "g", atHome: true)
            ]))
        instr3.timer = RecipeTimer(context: context).configured(time: 20, finishMessage: "Die Nudeln sind fertig. Hole sie aus dem Wasser", identifier: "Nudeltimer", amountOfInstr: 0)
        
        let instr4 = Instruction(context: context).configured(context: "adding",image: "", instruction: "Füge {Anzahl} {Einheit} {Zutat} dem Pfanneninhalt hinzu", posNr: 4)
        instr4.addToIngredients(NSSet(array: [
            Ingredient(context: context).configured(image: "tomatopaste", name: "Tomatenmark", measurement: 2, measurementUnit: "EL", atHome: false)
            ]))
        
        let instr5 = Instruction(context: context).configured(context: "seasoning",image: "", instruction: "Gebe 200 ml Wasser in die Pfanne. Würze die Tomatensoße mit {Anzahl} {Einheit} {Zutat}, {Anzahl} {Einheit} {Zutat}, {Anzahl} {Einheit} {Zutat} und {Anzahl} {Einheit} {Zutat}", posNr: 5)
        instr5.addToIngredients(NSSet(array: [
            Ingredient(context: context).configured(image: "blackpepper", name: "Pfeffer", measurement: 2, measurementUnit: "EL", atHome: false),
            Ingredient(context: context).configured(image: "salt", name: "Salz", measurement: 1, measurementUnit: "Prise", atHome: true),
            Ingredient(context: context).configured(image: "basil", name: "Basilikum", measurement: 8, measurementUnit: "Blätter", atHome: false),
            Ingredient(context: context).configured(image: "garlic", name: "Knoblauch", measurement: 1, measurementUnit: "Zehe", atHome: false)
            ]))
        //instr5.note = RecipeNote(context: context).configured(finishMessage: "Eine Prise Zucker rundet den Geschmack ab.", identifier: "SalzNotiz")
        
        let instr6 = Instruction(context: context).configured(context: "dishup", image: "", instruction: "Es kann nun angerichtet werden. Gebe zwei gehäufte Löffel Nudeln auf einen tiefen Teller und gebe die gewünschte Saucenmenge darüber. Lass es dir schmecken!", posNr: 6)
        
        recipe.addToInstructions(NSSet(array: [
            instr1, instr2, instr3, instr4, instr5, instr6
            ]))
        
        
        
        
        
        
        /*
        
        
        //SECOND RECIPE
        let recipe2 = Recipe(context: context)
        recipe2.name = "Spiegelei"
        recipe2.recipeImage = "pasta_bolognese"
        recipe2.category = "Beef"
        recipe2.cookingTime = 5
        
        //Add Ingredients to Recipe
        recipe2.addToIngredients(NSSet(array: [
            Ingredient(context: context).configured(image: "ei", name: "Eier", measurement: 2, measurementUnit: "", atHome: false),
            Ingredient(context: context).configured(image: "butter", name: "Butter", measurement: 1, measurementUnit: "EL", atHome: false),
            Ingredient(context: context).configured(image: "blackpepper", name: "Pfeffer", measurement: 1, measurementUnit: "Prise", atHome: false),
            Ingredient(context: context).configured(image: "salt", name: "Salz", measurement: 1, measurementUnit: "Prise", atHome: true)
            ]))
        
        //Create Instructions and add their Ingredients
        let rec2Instr1 = Instruction(context: context).configured(context: "cooking",image: "", instruction: "Erhitze eine Pfanne und schmelze {Anzahl} {Einheit} {Zutat}", posNr: 1)
        rec2Instr1.addToIngredients(NSSet(array: [
            Ingredient(context: context).configured(image: "butter", name: "Butter", measurement: 1, measurementUnit: "EL", atHome: false)
            ]))
        
        let rec2Instr2 = Instruction(context: context).configured(context: "cooking",image: "", instruction: "Gebe {Anzahl} {Zutat} hinzu", posNr: 2)
        rec2Instr2.addToIngredients(NSSet(array: [
                Ingredient(context: context).configured(image: "ei", name: "Eier", measurement: 2, measurementUnit: "", atHome: false)
            ]))
        
        let rec2Instr3 = Instruction(context: context).configured(context: "seasoning",image: "", instruction: "Würze die Eier mit {Anzahl} {Einheit} {Zutat}, {Anzahl} {Einheit} {Zutat}", posNr: 3)
        //rec2Instr3.note = RecipeNote(context: context).configured(finishMessage: "Eine Prise Paprikapulver sorgt für besonderen Geschmack.", identifier: "Spices")
        rec2Instr3.addToIngredients(NSSet(array: [
            Ingredient(context: context).configured(image: "blackpepper", name: "Pfeffer", measurement: 1, measurementUnit: "Prise", atHome: false),
            Ingredient(context: context).configured(image: "salt", name: "Salz", measurement: 1, measurementUnit: "Prise", atHome: true)
            ]))
        
        let rec2Instr4 = Instruction(context: context).configured(context: "dishup", image: "", instruction: "Es kann nun angerichtet werden. Lass es dir schmecken!", posNr: 4)

        
        recipe2.addToInstructions(NSSet(array: [
            rec2Instr1, rec2Instr2, rec2Instr3, rec2Instr4
            ]))
 
 */
        
        try saveContext()
        
    }
    
    func deleteAllData(_ entity:String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Delete all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            try deleteAllData("Recipe")
            do {
                try writeData()
            }catch {
                print("Failed to write")
            }
        }catch{
            print("Failed to delete")
        }
        
        //SpeechDetectionManager.sharedInstance.recordAndRecognizeSpeech()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Flavr")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

