//
//  DictionaryExtension.swift
//  Flavr
//
//  Created by Timon Fuß on 17.03.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import Foundation

extension Dictionary where Value: Equatable {
    
    /**
     Returns all keys mapped to the specified value.
     ```
     let dict = ["A": 1, "B": 2, "C": 3]
     let keys = dict.keysForValue(2)
     assert(keys == ["B"])
     assert(dict["B"] == 2)
     ```
     */
    func keysForValue(value: Value) -> [Key] {
        return flatMap { (key: Key, val: Value) -> Key? in
            value == val ? key : nil
        }
    }
}
