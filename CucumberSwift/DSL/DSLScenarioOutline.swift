//
//  DSLScenarioOutline.swift
//  CucumberSwift
//
//  Created by thompsty on 7/23/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation

struct ScenarioOutline: ScenarioDSL {
    var scenarios: [Scenario] = []
    
    @discardableResult init<T>(_ title:String, tags:[String] = [], headers: T.Type, line:UInt = #line, column:UInt = #column, @StepBuilder steps: (T) -> [DSLStep], examples: () -> [T]) {
        scenarios = examples().map {
            Scenario(with: steps($0),
                     title: title,
                     tags: tags,
                     position: Lexer.Position(line: line, column: column)) //TODO, FIX THIS
        }
    }
    
    @discardableResult init<T>(_ title:String, tags:[String] = [], headers: T.Type, line:UInt = #line, column:UInt = #column, @StepBuilder steps: (T) -> DSLStep, examples: () -> [T]) {
        scenarios = examples().map {
            Scenario(with: [steps($0)],
                     title: title,
                     tags: tags,
                     position: Lexer.Position(line: line, column: column)) //TODO, FIX THIS
        }
    }
}
