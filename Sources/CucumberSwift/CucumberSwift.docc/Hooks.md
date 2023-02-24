# Hooks

Hooks are used to tie into CucumberSwift's runtime. They are great for setting up preconditions before a feature, or cleaning up after it is completed.

## Types of Hooks
CucumberSwift comes with 6 hooks, Before/After Feature Before/After Scenario and Before/After step, use them like so

NOTE: Hooks can be setup in more than 1 place however each hook will only be called once
```swift
import Foundation
import XCTest
import CucumberSwift

extension Cucumber: StepImplementation {
    public var bundle: Bundle {
        class ThisBundle { }
        return Bundle(for: ThisBundle.self)
    }

    public func setupSteps() {
        BeforeFeature { feature in
            //called once before the feature, but can be setup in more than 1 file.
        }
        
        AfterFeature { feature in
            
        }
        
        BeforeScenario { scenario in
            
        }

        AfterScenario { scenario in
            
        }

        BeforeStep { step in
            
        }

        AfterStep = { step in
            
        }
    }
}
```

### Execution Order
If you never specify anything hooks will just execute in whatever order they appear in the code. However if you need specific control you can add a `priority` to hooks. The lower the priority, the earlier it executes. So a priority 1 executes before a priority 2.

Other cucumber engines might have different behaviour for hooks order. For example cucumber-jvm reverses order for `@After` hooks. I.e. the earlier the priority the later `@After` hook is executed. Also `@After` hooks are executed in reverse order of registering.
Option `reverseOrderForAfterHooks` can be overriden for `StepImplementation` and set to true to make similar behaviour.

NOTE: If you do *not* specify an order hooks with no priority will execute *after* hooks with a priority

```swift
import Foundation
import XCTest
import CucumberSwift

extension Cucumber: StepImplementation {
    public var bundle: Bundle {
        class ThisBundle { }
        return Bundle(for: ThisBundle.self)
    }

    // Uncomment if you want reverse order of 'after' hooks execution
    // public var reverseOrderForAfterHooks: Bool { true }

    public func setupSteps() {
        // This hook will execute last, because it uses UInt.max as a priority
        BeforeFeature(priority: .max) { feature in
            //called once before the feature, but can be setup in more than 1 file.
        }
        
        // This hook executes first, even though it is declared second
        BeforeFeature(priority: 1) { feature in
            //called once before the feature, but can be setup in more than 1 file.
        }
    }
}
```
