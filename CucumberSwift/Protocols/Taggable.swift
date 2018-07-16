//
//  Taggable.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 5/13/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
public protocol Taggable {
    var tags:[String] { get }
}
extension Taggable {
    func containsTag(_ tag:String) -> Bool {
        return !tags.filter { !$0.matches(for: tag).isEmpty }.isEmpty
    }
    static func isTag(_ line:String) -> Bool {
        return !line.matches(for: "^@(\\w+)(\\s*)$").isEmpty
    }
}
