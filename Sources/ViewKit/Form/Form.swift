//
//  Form.swift
//  
//
//  Created by Kyle on 2022/10/3.
//

import Vapor
import LeafKit
import Fluent

public protocol Form: LeafDataRepresentable {
    associatedtype Model: Fluent.Model

    var id: String? { get set }
    init()
    init(req: Request) throws

    func write(to model: Model)
    func read(from model: Model)
    func validate(req: Request) async throws -> Bool
}
