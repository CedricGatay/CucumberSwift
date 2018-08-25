Feature: CucumberSwift Library
The CucumberSwift library needs to work like Developers, QAs and Product Owners expect it to
This particular test pulls in the library much like they would and ensures it behaves
as expected

    Scenario: Before feature hook works correctly
        Given I have a before feature hook
        When I run the tests
        Then BeforeFeature gets called once per feature

    Scenario: Scenario with the same name does not collide
        Given I have a scenario defined
        When I run the tests
        Then The scenario runs without crashing

    Scenario: Scenario with the same name does not collide
        Given I have a scenario defined
            And The steps are slightly different
        When I run the tests
        Then The scenario runs without crashing
