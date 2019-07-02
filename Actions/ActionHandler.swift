//
//  ActionHandler.swift
//  Flavr
//
//  Created by Timon Fuß on 21.02.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import Foundation
import UIKit

class ActionHandler{
    
    public static let sharedInstance = ActionHandler()
    
    /**
     Performs Segues that are initiated by VoiceCommand
     - Parameter action: string-representation of action that should be performed.
     - Parameter ai: AI-Object that was return from NLP.
     */
    func handleAction(action: Action, ai: AI){
        if action.name.contains("showIngredients") || action.name.contains("beginIngredients"){
            if InformationState.sharedInstance.viewState != "Flavr.RecipeDetailviewViewController"{
                performSegueFromView(withIdentifier: "showIngredients")
            }
        }else if action.name.contains("showInstructions") || action.name.contains("beginInstructions"){
            if InformationState.sharedInstance.viewState != "Flavr.RecipeInstructionViewController"{
                performSegueFromView(withIdentifier: "showInstructions")
            }
            
        }
    }

    func performSegueFromView(withIdentifier: String){
        let viewController = UIApplication.shared.windows[0].rootViewController?.children[0].children[0] as! RecipeOverviewViewController
        viewController.performSegue(withIdentifier: withIdentifier, sender: nil)
    }
}
