//
//  RecipeInstructionViewController.swift
//  Flavr
//
//  Created by Timon Fuß on 21.02.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import UIKit

class RecipeInstructionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var instructionList: [Instruction]!
    var recipe : Recipe!
    var index: Int = 0
    var cellIndex = IndexPath()
    var test : InstructionCell!
    
    
    var currentInstruction: Instruction? {
        get {
            return instructionList[index]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.markFirstInstruction), name: NSNotification.Name(rawValue: "first"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.markNextInstruction(_ :)), name: NSNotification.Name(rawValue: "next"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.recipeFinished(_ :)), name: NSNotification.Name(rawValue: "recipeFinished"), object: nil)
        InformationState.sharedInstance.viewState = NSStringFromClass(self.classForCoder)
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return instructionList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "instructionCell") as! InstructionCell
        //let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "instructionCell")
        cell.layer.cornerRadius = 5
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.cellLabel?.text = instructionList[indexPath.row].instruction
        
        if instructionList[indexPath.row].timer != nil {
            if let time = instructionList[indexPath.row].timer?.time {
                cell.cellTime.text = "\(time)"
            }
            NotificationCenter.default.addObserver(self, selector: #selector(self.counter(_ :)), name: NSNotification.Name(rawValue: "updateTime"), object: nil)
        }
        return cell
    }

    /**
     Marks the first instruction on view
     */
    @objc func markFirstInstruction () {
        let cell = self.tableView.visibleCells.first as! InstructionCell
        cell.cellLabel.textColor = UIColor.Colors.systemOrange
    }
    
    /**
     Marks the next instruction on view
     - Parameter notification: contains index for element that has to be marked
     */
    @objc func markNextInstruction (_ notification : Notification) {
        let index = notification.object as! Int
        //Mark next Element
        let nextCell = self.tableView.visibleCells[index] as! InstructionCell
        nextCell.cellLabel.textColor = UIColor.Colors.systemOrange
        if nextCell.cellTime != nil {
            nextCell.cellTime.textColor = UIColor.Colors.systemOrange
            
        }
        //Unmark prev Element
        if index > 0 {
            let prevCell = self.tableView.visibleCells[index - 1] as! InstructionCell
            prevCell.cellLabel.textColor = UIColor.Colors.systemGray
        }
    }
    
    /**
     Sets TimerModule Value to its CoreData-Object to reload view
     - Parameter notification: contains TimeModule-Object (time-value for timer as int)
     */
    @objc func counter (_ notification: Notification) {
        let data = notification.object as! TimeModule
        if let index = data.index {
            if let timer = instructionList![index].timer {
                timer.time = Float(data.time)
            }
        }
        self.tableView.reloadData()
    }
    
    /**
     Performs segue after last instruction
     */
    @objc func recipeFinished(_ notification: Notification) {
        //performSegue(withIdentifier: "showOverview", sender: nil)
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    /**
     Prepares recipe-data for different kind of segues.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOverview" {
            InformationState.sharedInstance.contextState = [NSMutableDictionary:contextStatus]()
            print(InformationState.sharedInstance.contextState)
            let overView = segue.destination as! RecipeOverviewViewController
            overView.first = false
        }
    }
}
