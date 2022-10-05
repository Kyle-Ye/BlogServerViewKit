//
//  FileFormField.swift
//
//
//  Created by Kyle on 2021/6/27.
//

import Foundation
import LeafKit

public struct FileFormFiled: LeafDataRepresentable {
    public var value: String = ""
    public var error: String?
    public var data: Data?
    public var delete: Bool = false

    public init(value: String = "", error: String? = nil, data: Data? = nil, delete: Bool = false) {
        self.value = value
        self.error = error
        self.data = data
        self.delete = delete
    }
    
    public var leafData: LeafData {
        .dictionary([
            "value": .string(value),
            "error": .string(error),
            "data": .data(data),
            "delete": .bool(delete),
        ])
    }
}
