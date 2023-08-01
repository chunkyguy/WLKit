import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SLETests.allTests),
        testCase(VFLTests.allTests),
    ]
}
#endif
