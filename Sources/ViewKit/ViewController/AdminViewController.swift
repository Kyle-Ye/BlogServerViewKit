//
//  AdminViewController.swift
//
//
//  Created by Kyle on 2022/10/3.
//

import Fluent
import Leaf
import LeafKit
import Vapor

public protocol AdminViewController {
    associatedtype EditForm: Form where EditForm.Model == Model
    associatedtype Model: Fluent.Model & LeafDataRepresentable
    var idParamKey: String { get }
    var idPathComponent: PathComponent { get }
    var listView: String { get }
    var editView: String { get }
    func listView(req: Request) async throws -> View
    func beforeRender(req: Request, form: EditForm) async throws
    func render(req: Request, form: EditForm) async throws -> View
    func createView(req: Request) async throws -> View
    func beforeCreate(req: Request, model: Model, form: EditForm) async throws
    func create(req: Request) async throws -> Response
    func find(req: Request) async throws -> Model
    func updateView(req: Request) async throws -> View
    func beforeUpdate(req: Request, model: Model, form: EditForm) async throws
    func update(req: Request) async throws -> View
    func beforeDelete(req: Request, model: Model) async throws
    func delete(req: Request) async throws -> String
}

extension AdminViewController where Model.IDValue == UUID {
    public var idParamKey: String { "id" }
    public var idPathComponent: PathComponent { .init(stringLiteral: ":\(idParamKey)") }

    public func listView(req: Vapor.Request) async throws -> Vapor.View {
        let list = try await Model.query(on: req.db).all().map(\.leafData)
        return try await req.leaf.render(path: listView, context: [
            "title": .string("Blog admin"),
            "list": .array(list),
        ]).map { View(data: $0) }.get()
    }

    public func beforeRender(req _: Request, form _: EditForm) async throws {}

    public func render(req: Request, form: EditForm) async throws -> View {
        try await beforeRender(req: req, form: form)
        return try await req.leaf.render(path: editView, context: [
            "title": .string("Blog admin"),
            "edit": form.leafData,
        ]).map { View(data: $0) }.get()
    }

    public func createView(req: Vapor.Request) async throws -> View {
        try await render(req: req, form: EditForm())
    }

    public func beforeCreate(req _: Request, model _: Model, form _: EditForm) async throws {}

    public func create(req: Request) async throws -> Response {
        let form = try EditForm(req: req)
        let isValid = try await form.validate(req: req)
        guard isValid else { return try await render(req: req, form: form).encodeResponse(for: req).get() }
        let model = Model()
        form.write(to: model)
        try await beforeCreate(req: req, model: model, form: form)
        try await model.create(on: req.db)
        return req.redirect(to: "../\(model.id!.uuidString)")
    }

    public func find(req: Vapor.Request) async throws -> Model {
        guard let id = req.parameters.get(idParamKey),
              let uuid = UUID(uuidString: id)
        else {
            throw Abort(.badRequest)
        }
        guard let model = try await Model.find(uuid, on: req.db) else {
            throw Abort(.notFound)
        }
        return model
    }

    public func updateView(req: Request) async throws -> View {
        let model = try await find(req: req)
        let form = EditForm()
        form.read(from: model)
        return try await render(req: req, form: form)
    }

    public func beforeUpdate(req _: Request, model _: Model, form _: EditForm) async throws {}
    public func update(req: Request) async throws -> View {
        let form = try EditForm(req: req)
        let isValid = try await form.validate(req: req)
        guard isValid else { return try await render(req: req, form: form) }

        let model = try await find(req: req)
        try await beforeUpdate(req: req, model: model, form: form)
        form.write(to: model)
        try await model.update(on: req.db)
        form.read(from: model)
        return try await render(req: req, form: form)
    }

    public func beforeDelete(req _: Request, model _: Model) async throws {}
    public func delete(req: Request) async throws -> String {
        let model = try await find(req: req)
        try await beforeDelete(req: req, model: model)
        try await model.delete(on: req.db)
        return model.id!.uuidString
    }
}

// MARK: - Helper Methods on AdminViewController

extension AdminViewController where Model.IDValue == UUID {
    public func setupRoutes(on builder: RoutesBuilder,
                            as pathComponent: PathComponent,
                            create _: PathComponent = "new") {
        let base = builder.grouped(pathComponent)
        base.get(use: listView(req:))
        base.get("new", use: createView(req:))
        base.post("new", use: create(req:))
        base.get(":id", use: updateView(req:))
        base.post(":id", use: update(req:))
        base.delete(":id", use: delete(req:))
    }
}
