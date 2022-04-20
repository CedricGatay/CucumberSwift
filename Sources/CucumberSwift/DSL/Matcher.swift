//
//  Matcher.swift
//  CucumberSwift
//
//  Created by thompsty on 7/23/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation

public protocol Matcher {
    init(line: Int, file: StaticString)
    var keyword: Step.Keyword { get }
}

extension Matcher {
    @discardableResult public init(_ regex: String,
                                   class: AnyClass,
                                   selector: Selector,
                                   line: Int = #line,
                                   file: StaticString = #file) {
        self.init(line: line, file: file)
        Cucumber.shared.attachClosureToSteps(keyword: keyword, regex: regex, class: `class`, selector: selector, line: line, file: file)
    }
    @discardableResult public init(_ regex: String,
                                   callback:@escaping (([String], Step) -> Void),
                                   line: Int = #line,
                                   file: StaticString = #file) {
        self.init(line: line, file: file)
        Cucumber.shared.attachClosureToSteps(keyword: keyword, regex: regex, callback: callback, line: line, file: file)
    }
}
