//
//  StubGenerator.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/4/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
class StubGenerator {
    private static func executableSteps(for features:[Feature]) -> [Step] {
        var environment:[String:String] = ProcessInfo.processInfo.environment
        var steps = [Step]()
        if let tagNames = environment["CUCUMBER_TAGS"] {
            let tags = tagNames.components(separatedBy: ",")
            steps = features.filter { $0.containsTags(tags) }
                .flatMap{ $0.scenarios }.filter { $0.containsTags(tags) }
                .flatMap{ $0.steps }
        } else {
            steps = features.flatMap{ $0.scenarios }
                .flatMap{ $0.steps }
        }
        return steps
    }
    
    private static func regexForTokens(_ tokens:[Token]) -> String {
        var regex = ""
        for token in tokens {
            if case Token.match(let m) = token {
                regex += NSRegularExpression
                    .escapedPattern(for: m)
                    .replacingOccurrences(of: "\\", with: "\\\\", options: [], range: nil)
                    .replacingOccurrences(of: "\"", with: "\\\"", options: [], range: nil)
            } else if case Token.string(_) = token {
                regex += "\\\"(.*?)\\\""
            }
        }
        return regex.trimmingCharacters(in: .whitespaces)
    }
    
    static func getStubs(for features:[Feature]) -> [String] {
        var methods = [Method]()
        var lookup = [String:Method]()
        let executableSteps = self.executableSteps(for: features)
        executableSteps.filter{ $0.execute == nil }.forEach {
            let regex = regexForTokens($0.tokens)
            let stringCount = $0.tokens.filter { $0.isString() }.count
            let matchesParameter = (stringCount > 0) ? "matches" : "_"
            var method = Method(keyword: $0.keyword, regex: regex, matchesParameter: matchesParameter, variables: [(type: "string", count: stringCount)])
            if let m = lookup[regex] {
                method = m
                if (!method.keyword.contains($0.keyword)) {
                    method.insertKeyword($0.keyword)
                }
            } else {
                methods.append(method)
                lookup[regex] = method
            }
        }
        return methods.map { method in
            let canMatchAll = !(executableSteps.filter { $0.execute != nil }.contains { !$0.match.matches(for: method.regex).isEmpty })
            return method.generateSwift(matchAllAllowed: canMatchAll)
        }
    }
}
