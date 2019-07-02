//
//  InstructionManager.swift
//  Flavr
//
//  Created by Timon Fuß on 21.02.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import Foundation
import UIKit

class InstructionManager {
    /// sharedInstance: the InstructionManager singleton
    public static let sharedInstance = InstructionManager()
    
    var index: Int = 0
    var instructionList : [Instruction]!
    var ingredientsList : [Ingredient]!
    var moduleList: [Module] = []
    var lastUsed = ""
    var spokenIngredients = 0
    var finishedIngredients = false
    private var _recipe: Recipe?
    
    var recipe: Recipe? {
        get {
            return _recipe
        }
        set {
            _recipe = newValue
        }
    }
    
    var currentInstruction: Instruction? {
        get {
            return instructionList[index]
        }
    }
    
    /**
     Preparing InstructionManager with Recipeinformation
     - Parameter recipe: Recipe picked by user.
     */
    public func prepare (recipe : Recipe){
        self.recipe = recipe
        NotificationCenter.default.addObserver(self, selector: #selector(self.timerStopped(_ :)), name: NSNotification.Name(rawValue: "finish"), object: nil)
        fillInstruction(recipe: recipe)
        fillIngredients(recipe: recipe)
    }
    
    /**
     Execute Instruction
     - Parameter action: String-Object for Action that should be performed.
     - Parameter ai: AI-Object that is build from NLP-Response.
     */
    public func handleInstruction(action: Action, ai: AI){
        let infoState = InformationState.sharedInstance
        let synthVoice = SynthesisVoiceManager.sharedInstance
        let instrManager = InstructionManager.sharedInstance
        var instruction : Instruction?
        
        if action.name.contains("show"){
            ActionHandler.sharedInstance.handleAction(action: action, ai: ai)
            synthVoice.speak(string: ai.intent.speech ?? "")
        }else if action.name.contains("TimerCreate"){
            if ai.intent.extraParams.count > 0 {
                if let name = ai.intent.extraParams["TimerName"], let timerDuration = ai.intent.extraParams["TimerDuration"]{
                    let timerName = name as! String
                    let finishMessage = "Der \(timerName) ist abgelaufen!"
                    let timer = Time(name: timerName, time: timerDuration as! Int, finish: finishMessage, index: self.index)
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    instructionList[index].timer = RecipeTimer(context: context).configured(time: Float(timerDuration as! Int), finishMessage: finishMessage, identifier: timerName, amountOfInstr: 0)
                    moduleList.append(timer)
                    timer.start()
                    synthVoice.speak(string: "Ich habe einen \(timerName) mit einem Startwert von \(timerDuration as! Int) Sekunden gestellt.")
                }
            }
        }else if action.name.contains("TimerRemainingTime"){
            for module in moduleList {
                if module.moduleType ==  ModuleTypes.Time {
                    let speech = infoState.adjustSystemAnswer(forTime: ai.intent.speech ?? "", module: module)
                    lastUsed = module.identifier
                    synthVoice.speak(string: speech)
                }
            }
        }else if action.name.contains("TimerSetTime"){
            for module in moduleList {
                if module.moduleType ==  ModuleTypes.Time {
                    let timeModule = module as! Time
                    
                    if ai.intent.extraParams.count > 0 {
                        if let name = ai.intent.extraParams["TimerName"], let timerDuration = ai.intent.extraParams["TimerDuration"]{
                            let timerName = name as! String
                            if timeModule.identifier.lowercased() == timerName.lowercased() {
                                timeModule.setTimeTo(time: timerDuration as! Int)
                                synthVoice.speak(string: "Ich habe den \(timeModule.identifier) auf \(timerDuration as! Int) Sekunden gestellt.")
                                lastUsed = timerName
                            }
                        }
                    }
                }
            }
        }else if action.name.contains("TimerNotFinished"){
            for module in moduleList {
                if module.moduleType ==  ModuleTypes.Time {
                    let timeModule = module as! Time
                    if timeModule.identifier == lastUsed {
                        timeModule.setTimeTo(time: timeModule.initTime/2)
                        synthVoice.speak(string: "Ich habe den \(timeModule.identifier) nochmal etwas verlängert")
                    }
                }
            }
        }else if action.name.contains("nextIngredient"){
            if finishedIngredients {
                synthVoice.speak(string: "Du benötigst keine weiteren Zutaten.")
            }else {
                let string = "\(ingredientsList[spokenIngredients].measurement) \(ingredientsList[spokenIngredients].measurementUnit!) \(ingredientsList[spokenIngredients].name!)"
                synthVoice.speak(string: string)
                if spokenIngredients < ingredientsList.count - 1 {
                    spokenIngredients += 1
                }else{
                    finishedIngredients = true
                }
            }
        }else if action.name.contains("IngredientsHowMuch"){
            if infoState.viewState == "Flavr.RecipeInstructionViewController"{
                var ingredientForActInstr: [Ingredient] = []
                if let ingredients = self.currentInstruction!.ingredients?.allObjects as? [Ingredient] {
                    ingredients.enumerated().forEach{offset, ingredient in
                        ingredientForActInstr.append(ingredient)
                    }
                    
                    if ingredientForActInstr.count > 0 {
                        let speech = InformationState.sharedInstance.adjustSystemAnswer(list: ingredientForActInstr, speech: ai.intent.speech ?? "")
                        synthVoice.speak(string: speech)
                    }else{
                        synthVoice.speak(string: "Für diesen Arbeitsschritt benötigst du keine Zutaten.")
                    }
                }
            }
        }else if action.name.contains("IngredientForInstr"){
            if infoState.viewState == "Flavr.RecipeInstructionViewController"{
                var ingredientForActInstr: [Ingredient] = []
                var ingredientName = ""
                if ai.intent.extraParams.count > 0 {
                    if let ingredient = ai.intent.extraParams["Ingredient"]{
                        ingredientName = ingredient as! String
                    }
                }
                if let ingredients = self.currentInstruction!.ingredients?.allObjects as? [Ingredient] {
                    ingredients.enumerated().forEach{offset, ingredient in
                        if ingredient.name == ingredientName {
                            ingredientForActInstr.append(ingredient)
                        }
                    }
                    if ingredientForActInstr.count > 0 {
                        let speech = InformationState.sharedInstance.adjustSystemAnswer(list: ingredientForActInstr, speech: ai.intent.speech ?? "")
                        synthVoice.speak(string: speech)
                    }else{
                        synthVoice.speak(string: "Für diesen Arbeitsschritt benötigst du keine \(ingredientName).")
                    }
                }
            }
        }else if action.name.contains("beginIngredients"){
            if infoState.viewState == "Flavr.RecipeOverviewViewController"{
                ActionHandler.sharedInstance.handleAction(action: action, ai: ai)
            }
            let speech = InformationState.sharedInstance.adjustSystemAnswer(list: ingredientsList, speech: ai.intent.speech ?? "")
            synthVoice.speak(string: speech)
        }else if action.name.contains("PortionsUp"){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PortionsUp"), object: nil)
            synthVoice.speak(string: "Ich habe die Portionen um 1 erhöht.")
        }else if action.name.contains("PortionsDown"){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PortionsDown"), object: nil)
            synthVoice.speak(string: "Ich habe die Portionen um 1 verringert.")
        }else if action.name.contains("PortionsSetTo"){
            let value = ai.intent.parameters[0]["parameters"] as! NSMutableDictionary
            if let portions = value["Portions"]{
                let amountPortion = portions as! Int
                if amountPortion > 0 {
                    let speech = InformationState.sharedInstance.adjustSystemAnswer(forPortions: ai.intent.speech ?? "", number: amountPortion)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setAmountPortions"), object: portions)
                    synthVoice.speak(string: speech)
                }else{
                    synthVoice.speak(string: "Ich kann die Personenanzahl nicht auf \(amountPortion) setzen.")
                }
            }
        }else if action.name.contains("beginInstructions"){
            if infoState.viewState == "Flavr.RecipeDetailviewViewController"{
                ActionHandler.sharedInstance.handleAction(action: action, ai: ai)
                let instruction = instrManager.getFirstInstruction()
                synthVoice.speak(string: instruction.instruction ?? "")
                checkIfNoteModule(instruction: instruction)
            }else if infoState.viewState == "Flavr.RecipeInstructionViewController"{
                let instruction = instrManager.getFirstInstruction()
                synthVoice.speak(string: instruction.instruction ?? "")
                checkIfNoteModule(instruction: instruction)
            }
        }else if action.name.contains("prevInstruction"){
            instruction = self.getPrevInstruction()
            synthVoice.speak(string: instruction?.instruction ?? "")
        }else if action.name.contains("nextInstruction"){
            instruction = self.getNextInstruction()
            synthVoice.speak(string: instruction?.instruction ?? "")
            checkIfNoteModule(instruction: instruction!)
        }else if action.name.contains("fallback"){
            synthVoice.speak(string: ai.intent.speech ?? "")
        }else{
            synthVoice.speak(string: ai.intent.speech ?? "")
        }
    }
    
    /**
     Fill Instruction-Array ordered by position
     - Parameter recipe: Recipe that is chosen from user.
     */
    public func fillInstruction (recipe : Recipe) {
        self.instructionList = []
        var tmparray : [Instruction] = []
        
        if let instructions = recipe.instructions?.allObjects as? [Instruction] {
            instructions.enumerated().forEach{offset, instruction in
                tmparray.append(instruction)
            }
        }
        instructionList = tmparray.sorted(by: {$0.posNr < $1.posNr})
    }
    
    /**
     Fill Ingredient-Array
     - Parameter recipe: Recipe that is chosen from user.
     */
    public func fillIngredients (recipe : Recipe) {
        self.ingredientsList = []
        
        if let ingredients = recipe.ingredients?.allObjects as? [Ingredient] {
            ingredients.enumerated().forEach{offset, ingredient in
                self.ingredientsList.append(ingredient)
            }
        }
    }
    
    /**
     Get first Instruction in InstructionList
     - Returns: current Instruction
     */
    public func getFirstInstruction () -> Instruction {
        self.index = 0
        
        if currentInstruction?.timer != nil{
            let timer = currentInstruction?.timer
            let instructionTimer = Time(name: timer?.identifier ?? "", time: Int(timer!.time), finish: timer?.finishMessage ?? "", index: index)
            moduleList.append(instructionTimer)
            instructionTimer.start()
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "first"), object: nil)
        return currentInstruction!
    }
    
    /**
     Get previous Instruction in InstructionList
     - Returns: previous Instruction
     */
    public func getPrevInstruction () -> Instruction{
        if self.index > 0 {
            self.index -= 1
        }else {
            self.index = 0
        }
        
        return currentInstruction!
    }
    
    /**
     Get next Instruction in InstructionList
     - Returns: next Instruction
     */
    public func getNextInstruction () -> Instruction? {
        if self.index < self.instructionList.count - 1 {
            self.index += 1
        }
        if currentInstruction?.timer != nil{
            let timer = currentInstruction?.timer
            let instructionTimer = Time(name: timer?.identifier ?? "", time: Int(timer!.time), finish: timer?.finishMessage ?? "", index: index)
            moduleList.append(instructionTimer)
            instructionTimer.start()
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "next"), object: self.index)
        return currentInstruction!
    }
    
    /**
     Check if current Instruction has deposited NoteModule
     - Parameter instruction: that should be checked
     */
    private func checkIfNoteModule(instruction: Instruction) {
        if instruction.note != nil {
            let note = instruction.note
            let instructionNote = Notes(name: note?.identifier ?? "", finish: note?.finishMessage ?? "")
            moduleList.append(instructionNote)
            instructionNote.start()
        }
    }
    
    /**
     Get Module by its identifier
     - Parameter identifier: name of Module
     - Returns: Module for given identifier
     */
    private func getModuleByName(identifier: String) -> Module? {
        for module in moduleList {
            if identifier == module.identifier {
                return module
            }
        }
        return nil
    }
    
    /**
     Objective-C-/Notificationfunction that sets last used Module to timer after it finished
     - Parameter notification: TimeModule that finished.
     */
    @objc func timerStopped(_ notification: Notification) {
        let data = notification.object as! TimeModule
        self.lastUsed = data.identifier
    }
    
}

