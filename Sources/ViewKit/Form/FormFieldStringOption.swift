//
//  FormFieldStringOption.swift
//  
//
//  Created by Kyle on 2021/4/1.
//

import LeafKit

public struct FormFieldStringOption: LeafDataRepresentable {
    public let key: String
    public let label: String

    public init(key: String, label: String) {
        self.key = key
        self.label = label
    }
    
    public var leafData: LeafData {
        [
            "key": .string(key),
            "label": .string(label),
        ]
    }
}
