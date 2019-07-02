//
//  RecipeDetailviewViewController.swift
//  Flavr
//
//  Created by Timon Fuß on 09.02.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import UIKit

class RecipeDetailviewViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var plusButton: RoundButton!
    @IBOutlet weak var minusButton: RoundButton!
    @IBOutlet weak var portions: UILabel!
    
    let sectionHeaderView = "SectionHeaderView"
    var sectionCategories = [CollectionViewCategory.Home, CollectionViewCategory.Buy]
    
    var ingredientArray : [Ingredient]!
    var ingredientArrayHome : [Ingredient]!
    var recipe : Recipe!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InformationState.sharedInstance.viewState = NSStringFromClass(self.classForCoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.plusIngredient(_:)), name: NSNotification.Name(rawValue: "PortionsUp"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.minusIngredient(_:)), name: NSNotification.Name(rawValue: "PortionsDown"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setIngredientsForPortions(_:)), name: NSNotification.Name(rawValue: "setAmountPortions"), object: nil)
        
        let itemSizeWidth = UIScreen.main.bounds.width/3 - 10
        let itemSizeHeight = UIScreen.main.bounds.height/5
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: itemSizeWidth, height: itemSizeHeight)
        
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        myCollectionView.collectionViewLayout = layout
        
    }
    
    /**
     Adds one Portion and increase recipe-Ingredients.
     */
    @IBAction func plusIngredient(_ sender: Any) {
        let oldAmount = Int(portions.text!)!
        let newAmount = Int(portions.text!)! + 1
        portions.text = "\(newAmount)"
        
        setNewIngredientValue(oldValue: oldAmount, newValue: newAmount)
        
        self.myCollectionView.reloadData()
    }
    
    /**
     Subtract one Portion and decrease recipe-Ingredients.
     */
    @IBAction func minusIngredient(_ sender: Any) {
        let oldAmount = Int(portions.text!)!
        var newAmount = 0
        if oldAmount > 1 {
            newAmount = Int(portions.text!)! - 1
            portions.text = "\(newAmount)"
            
            setNewIngredientValue(oldValue: oldAmount, newValue: newAmount)
        }
        self.myCollectionView.reloadData()
        
    }
    
    /**
     Sets Portion to Value, received from NLP.
     - Parameter notification: contains amaount of portions set by user
     */
    @objc func setIngredientsForPortions (_ notification: Notification) {
        let newAmount = notification.object as! Int
        let oldAmount = Int(portions.text!)!
        
        setNewIngredientValue(oldValue: oldAmount, newValue: newAmount)
        self.myCollectionView.reloadData()
        portions.text = "\(newAmount)"
    }
    
    /**
     Mathematical formula to set Ingredients-measurements for amount of Portions.
     - Parameter oldValue: amount of Portion before setting newValue
     - Parameter newValue: new amount of Portion after user interaction
     */
    private func setNewIngredientValue(oldValue: Int, newValue: Int) {
        if let ingredients = recipe.ingredients?.allObjects as? [Ingredient] {
            for ingredient in ingredients {
                ingredient.measurement = (ingredient.measurement * Float(newValue)) / Float(oldValue)
            }
        }
        
        if let instructions = recipe.instructions?.allObjects as? [Instruction] {
            for instruction in instructions {
                if let ingredients = instruction.ingredients?.allObjects as? [Ingredient]{
                    for ingredient in ingredients {
                        ingredient.measurement = (ingredient.measurement * Float(newValue)) / Float(oldValue)
                    }
                }
            }
        }
    }
    
    /**
     Prepares recipe-data for different kind of segues.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showInstructions" {
            let recipeInstructions = segue.destination as! RecipeInstructionViewController
            recipeInstructions.recipe = self.recipe
            recipeInstructions.instructionList = []
            var tmparray : [Instruction] = []
            
            if let instructions = recipe.instructions?.allObjects as? [Instruction] {
                instructions.enumerated().forEach{offset, instruction in
                    tmparray.append(instruction)
                }
            }
            recipeInstructions.instructionList = tmparray.sorted(by: {$0.posNr < $1.posNr})
        }
    }
    
    @IBAction func startInstructions(_ sender: Any) {
        performSegue(withIdentifier: "showInstructions", sender: nil)
    }
    
    //Number of Views
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return ingredientArray.count

    }
    
    //Populate view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! IngredientCell
            cell.ingredientView.image = UIImage(named: ingredientArray[indexPath.row].image ?? "" + ".png")
            cell.ingredientName.text = "\(ingredientArray[indexPath.row].measurement) \(ingredientArray[indexPath.row].measurementUnit ?? "") \(ingredientArray[indexPath.row].name ?? "")"
            return cell
    }
}
