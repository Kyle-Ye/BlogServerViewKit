//
//  StringFormField.swift
//  
//
//  Created by Kyle on 2021/3/31.
//

import Foundation
import LeafKit

public struct StringFormField: LeafDataRepresentable {
    public var value:String = ""
    public var error:String?
    
    public init(value: String = "", error: String? = nil) {
        self.value = value
        self.error = error
    }
    
    public var leafData: LeafData{
        [
            "value": .string(value),
            "error": .string(error),
        ]
    }
}
