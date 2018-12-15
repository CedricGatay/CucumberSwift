//
//  CucumberTestCase.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/25/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

class CucumberTest: XCTestCase {
    //A test case needs at least one test to trigger the observer
    override class var defaultTestSuite: XCTestSuite {
        let suite = XCTestSuite(forTestCaseClass: CucumberTest.self)
        
        var tests = [XCTestCase?]()
        Cucumber.shared.features.removeAll()
        (Cucumber.shared as? StepImplementation)?.setupSteps()
        if let bundle = (Cucumber.shared as? StepImplementation)?.bundle {
            Cucumber.shared.readFromFeaturesFolder(in: bundle)
        }
        createTestCaseForStubs(&tests)
        for feature in Cucumber.shared.features.taggedElements(with: Cucumber.shared.environment, askImplementor: false) {
            let className = feature.title.camelCasingString().capitalizingFirstLetter() + "|"
            for scenario in feature.scenarios.taggedElements(with: Cucumber.shared.environment, askImplementor: true) {
                createTestCaseFor(className:className, scenario: scenario, tests: &tests)
            }
        }
        tests.compactMap { $0 }.forEach { suite.addTest($0) }
        return suite
    }
    
    private static func createTestCaseForStubs(_ tests:inout [XCTestCase?]) {
        let generatedSwift = Cucumber.shared.generateUnimplementedStepDefinitions()
        if (!generatedSwift.isEmpty) {
            tests.append(XCTestCaseGenerator.initWithClassName("Generated Steps", XCTestCaseMethod(name: "GenerateStepsStubsIfNecessary", closure: {
                XCTContext.runActivity(named: "Pending Steps") { activity in
                    let attachment = XCTAttachment(uniformTypeIdentifier: "swift", name: "GENERATED_Unimplemented_Step_Definitions.swift", payload: generatedSwift.data(using: .utf8), userInfo: nil)
                    attachment.lifetime = .keepAlways
                    activity.add(attachment)
                }
            })))
        }
    }
    
    private static func createTestCaseFor(className:String, scenario: Scenario, tests:inout [XCTestCase?]) {
        for step in scenario.steps {
            let testCase = XCTestCaseGenerator.initWithClassName(className.appending(scenario.title.camelCasingString().capitalizingFirstLetter()), XCTestCaseMethod(name: "\(step.keyword.toString()) \(step.match)".capitalizingFirstLetter().camelCasingString(), closure: {
                guard !Cucumber.shared.failedScenarios.contains(where: { $0 === step.scenario }) else { return }
                step.startTime = Date()
                Cucumber.shared.currentStep = step
                Cucumber.shared.setupBeforeHooksFor(step)
                Cucumber.shared.BeforeStep?(step)
                _ = XCTContext.runActivity(named: "\(step.keyword.toString()) \(step.match)") { _ in
                    step.execute?(step.match.matches(for: step.regex), step)
                    if (step.execute != nil && step.result != .failed) {
                        step.result = .passed
                    }
                }
            }))
            testCase?.addTeardownBlock {
                Cucumber.shared.AfterStep?(step)
                Cucumber.shared.setupAfterHooksFor(step)
                step.endTime = Date()
            }
            testCase?.continueAfterFailure = true
            tests.append(testCase)
        }
    }
    final func testGherkin() {
        XCTAssert(Gherkin.errors.isEmpty, "Gherkin language errors found:\n\(Gherkin.errors.joined(separator: "\n"))")
    }
}
