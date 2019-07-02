//
//  RoundButton.swift
//  Flavr
//
//  Created by Timon Fuß on 10.02.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class RoundButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            refreshCorners(value: cornerRadius)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func refreshCorners(value: CGFloat) {
        layer.cornerRadius = value
    }
    
    func sharedInit() {
        refreshCorners(value: cornerRadius)
    }
}
