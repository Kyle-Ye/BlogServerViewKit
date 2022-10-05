//
//  StringSelectionFormField.swift
//  
//
//  Created by Kyle on 2021/4/1.
//

import Foundation
import LeafKit

public struct StringSelectionFormField: LeafDataRepresentable {
    public var value: String = ""
    public var error: String?
    public var options: [FormFieldStringOption] = []
    
    public init(value: String = "", error: String? = nil, options: [FormFieldStringOption] = []) {
        self.value = value
        self.error = error
        self.options = options
    }
    
    public var leafData: LeafData {
        .dictionary([
            "value": .string(value),
            "error": .string(error),
            "options": .array(options.map(\.leafData)),
        ])
    }
}
