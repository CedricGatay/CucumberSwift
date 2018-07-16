//
//  Feature.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
public class Feature : Taggable {
    public private(set)  var title = ""
    public private(set)  var description = ""
    public private(set)  var scenarios = [Scenario]()
    public private(set)  var uri:String = ""
    public internal(set) var tags = [String]()
    
    init(with lines:[(scope: Scope, string: String)], uri:String? = nil) {
        parseTags(inLines: lines)
        let detagged = lines.filter{ !Feature.isTag($0.string) }
        self.uri ?= uri
        title ?= detagged.first?.string.matches(for: "^(?:Feature)(?:\\s*):?(?:\\s*)(.*?)$").last
        for (i, line) in detagged.enumerated() {
            if (i == 0) { continue }
            if (line.scope == .feature) {
                description += "\(line.string)\n"
            }
        }
        scenarios = allSectionsFor(parentScope: .scenario,
                                   inLines: lines.filter { $0.scope != .feature })
                    .flatMap{ Scenario(with: $0, tags: tags) }
        let backgroundSteps = allSectionsFor(parentScope: .background,
                                             inLines: lines)
            .flatMap{ $0 }
            .filter { $0.scope == .step }
            .map { (line) -> Step? in
                if (!Feature.isTag(line.string)) {
                    return Step(with: line)
                }
                return nil
            }
            .flatMap{ $0 }
        for scenario in scenarios {
            scenario.steps.insert(contentsOf: backgroundSteps, at: 0)
        }
    }
    
    init(with lines:[[Token]], uri:String? = nil) {
        self.uri ?= uri
        var scope:Scope = .feature
        var scenarioLines = [[Token]]()
        var foundIdentifierInScope = false
        for line in lines {
            guard let firstToken = line.first else { continue }
            if let firstIdentifier = line.firstIdentifier(),
            case Token.identifier(let id) = firstIdentifier {
                foundIdentifierInScope = true
                let s = Scope.scopeFor(str: id)
                if (s != .unknown) {
                    scope = s
                }
                if (s == .feature) {
                    title += line.removingScope().stringAggregate
                }
                if (scope == .feature && s == .unknown) {
                    description += line.stringAggregate
                    description += "\n"
                }
            }
            if firstToken.isTag() &&
                scope == .feature &&
                !foundIdentifierInScope {
                for token in line {
                    if case Token.tag(let tag) = token {
                        self.tags.append(tag)
                    }
                }
            }
            if (firstToken.isTag() && foundIdentifierInScope) {
                scope = .scenario
            }
            if (scope != .feature) {
                scenarioLines.append(line)
            }
        }
        scenarios = scenarioLines.groupBy(.scenario).compactMap { Scenario(with: $0, tags:tags) }
    }
    
    private func parseTags(inLines lines:[(scope: Scope, string: String)]) {
        for line in lines {
            if line.scope == .feature && Feature.isTag(line.string),
                let tagName = line.string.matches(for: "^@(\\w+)(?:\\s*)$").last {
                tags.append(tagName)
            }
        }
    }
    
    func allSectionsFor(parentScope:Scope, inLines lines:[(scope: Scope, string: String)]) -> [[(scope: Scope, string: String)]] {
        var linesInScope = [(scope: Scope, string: String)]()
        var allSections = [[(scope: Scope, string: String)]]()
        var scope = parentScope
        for (i, line) in lines.enumerated() {
            if  let nextLine = lines[safe: i + 1],
                Feature.isTag(line.string) {
                linesInScope.append((scope: nextLine.scope, string: line.string))
                continue
            }
            if (line.scope.priority == parentScope.priority) {
                scope = line.scope
            }
            if (line.scope.priority == parentScope.priority) {
                if let prev = lines[safe: i - 1] {
                    if (!Feature.isTag(prev.string)) {
                        if (!linesInScope.isEmpty) {
                            allSections.append(linesInScope)
                        }
                        linesInScope.removeAll()
                    }
                } else {
                    if (!linesInScope.isEmpty) {
                        allSections.append(linesInScope)
                    }
                    linesInScope.removeAll()
                }
            }
            if (scope == parentScope) {
                linesInScope.append(line)
            }
        }
        if (!linesInScope.isEmpty) {
            allSections.append(linesInScope)
        }
        return allSections
    }
    
    func containsTags(_ tags:[String]) -> Bool {
        if (!tags.filter{ containsTag($0) }.isEmpty) {
            return true
        }
        if (!scenarios.filter{ $0.containsTags(tags) }.isEmpty) {
            return true
        }
        return false
    }
    
    func toJSON() -> [String:Any] {
        return [
            "uri": uri,
            "id" : title.lowercased().replacingOccurrences(of: " ", with: "-"),
            "name" : title,
            "description" : description,
            "keyword" : "Feature",
            "elements" : scenarios.map { $0.toJSON() }
        ]
    }
}
