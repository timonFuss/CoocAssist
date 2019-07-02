//
//  RecipeOverviewViewController.swift
//  Flavr
//
//  Created by Timon Fuß on 09.02.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import UIKit
import CoreData
import Speech

class RecipeOverviewViewController: UIViewController {

    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var recipeCookingTime: UILabel!
    @IBOutlet weak var recipeCategoryImage: UIImageView!
    
    var recipe : Recipe!
    var first = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InformationState.sharedInstance.viewState = NSStringFromClass(self.classForCoder)

        if first{
            SFSpeechRecognizer.requestAuthorization{ authStatus in
                if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized {
                    SpeechDetectionManager.sharedInstance.recordAndRecognizeSpeech()
                }
            }
        }
        // Do any additional setup after loading the view.
        do {
            self.recipe = try getOneRecipe()
            setData(recipe: self.recipe)
            InstructionManager.sharedInstance.prepare(recipe: self.recipe)
        } catch  {
            print("Couldnt read recipe")
        }
    }
    
    /**
     Prepares Data for different kind of Segues
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showIngredients" {
            let recipeDetail = segue.destination as! RecipeDetailviewViewController
            recipeDetail.recipe = self.recipe
            recipeDetail.ingredientArray = []
            
            if let ingredients = self.recipe.ingredients?.allObjects as? [Ingredient] {
                ingredients.enumerated().forEach{offset, ingredient in
                        recipeDetail.ingredientArray.append(ingredient)
                }
            }
        }
        
        if segue.identifier == "showInstructions" {
            let recipeInstructions = segue.destination as! RecipeInstructionViewController
            recipeInstructions.recipe = self.recipe
            recipeInstructions.instructionList = []
            var tmparray : [Instruction] = []
            
            if let instructions = self.recipe.instructions?.allObjects as? [Instruction] {
                instructions.enumerated().forEach{offset, instruction in
                    if let ingredients = instruction.ingredients?.allObjects as? [Ingredient] {
                        var instr = instruction.instruction
                        for ingredient in ingredients {
                            instr = instr!.replaceFirst(of: "{Anzahl}", with: "\(ingredient.measurement)")
                            instr = instr!.replaceFirst(of: "{Einheit}", with: "\(ingredient.measurementUnit!)")
                            instr = instr!.replaceFirst(of: "{Zutat}", with: "\(ingredient.name!)")
                        }
                        instruction.instruction = instr
                    }
                    
                    tmparray.append(instruction)
                }
            }
            recipeInstructions.instructionList = tmparray.sorted(by: {$0.posNr < $1.posNr})
        }
    }
    
    @IBAction func tappedRecipe(_ sender: Any) {
        performSegue(withIdentifier: "showIngredients", sender: nil)
    }
    
    func printRecipe(recipe : Recipe) {
        print(recipe.name ?? "", recipe.category ?? "", recipe.cookingTime)
        
        if let ingredients = recipe.ingredients?.allObjects as? [Ingredient], ingredients.count > 0 {
            ingredients.enumerated().forEach{offset, ingredient in
                print("Ingredient #\(offset + 1)")
                print(ingredient.measurement)
                print(ingredient.measurementUnit ?? "")
                print(ingredient.name ?? "")
                print("__________________")
            }
        }
        
        if let instructions = recipe.instructions?.allObjects as? [Instruction], instructions.count > 0 {
            instructions.enumerated().forEach{offset, instruction in
                print("Instructions #\(offset + 1)")
                print("POSNR: \(instruction.posNr)")
                print(instruction.instruction ?? "")
                print("__________________")
            }
        }
    }
    
    /**
     Sets recipe Data to UI-Elements.
     - Parameter recipe: Displayed recipe.
     */
    func setData(recipe : Recipe) {
        recipeImage.image = UIImage(named: recipe.recipeImage ?? "")
        recipeTitle.text = recipe.name
        recipeCookingTime.text = "\(recipe.cookingTime) min."
        recipeCategoryImage.image = UIImage(named: "Vegetarian_Logo")
    }
    
    /**
     Reads recipe object from CoreData-Stack.
     - Parameter recipe: Displayed recipe.
     */
    func getOneRecipe() throws -> Recipe {
        var context: NSManagedObjectContext?{
            return (UIApplication.shared.delegate as? AppDelegate)?
                .persistentContainer.viewContext
        }
        
        let recipeFetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        recipeFetchRequest.fetchLimit = 1
        recipeFetchRequest.relationshipKeyPathsForPrefetching = ["ingredients", "instructions"]
        let recipes = try context?.fetch(recipeFetchRequest)
        guard let recipe = recipes!.first,
            recipes?.count == recipeFetchRequest.fetchLimit else {
                throw ReadDataExceptions.moreThatOneRecipeCameBack
        }
        return recipe
    }
    
    /**
     Reads second recipe object from CoreData-Stack.
     - Parameter recipe: Displayed recipe.
     */
    func getSecondRecipe() throws -> Recipe {
        var context: NSManagedObjectContext?{
            return (UIApplication.shared.delegate as? AppDelegate)?
                .persistentContainer.viewContext
        }
        
        let recipeFetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        recipeFetchRequest.relationshipKeyPathsForPrefetching = ["ingredients", "instructions"]
        let recipes = try context?.fetch(recipeFetchRequest)
        let recipe: Recipe!
        if self.first {
            recipe = recipes![0]
        }else {
            recipe = recipes![1]
        }
        return recipe
    }
}


extension String {
    
    public func replaceFirst(of pattern:String,
                             with replacement:String) -> String {
        if let range = self.range(of: pattern){
            return self.replacingCharacters(in: range, with: replacement)
        }else{
            return self
        }
    }
    
}
