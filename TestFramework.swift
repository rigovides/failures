import UIKit

struct TestResult {
    var runCount: Int = 0
    var errorCount: Int = 0
    
    mutating func testStarted() {
        runCount += 1
    }
    mutating func testFailed() {
        errorCount += 1
    }
    var summary: String {
        get {
            return "\(runCount) run, \(errorCount) failed"
        }
    }
}

class TestCase: NSObject {
    var name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    func setUp() {}
    func tearDown() {}
    
    func run() -> TestResult {
        self.setUp()
        var result = TestResult()
        result.testStarted()
        
        do {
            try self.perform(Selector(name))
        }
        catch {
            result.testFailed()
        }
        
        self.tearDown()
        return result
    }
}

class WasRun: TestCase {
    var log = ""
    
    override func setUp() {
        self.log = "setUp "
    }
    
    @objc func testMethod() {
        self.log += "testMethod "
    }
    
    @objc func testBrokenMethod() throws {
        throw NSError()
    }
    
    override func tearDown() {
        self.log += "tearDown "
    }
}

//bootstrap test suite
class TestCaseTest: TestCase {
    
    var test: WasRun!
    
    override func setUp() {
        self.test = WasRun("testMethod")
    }
    
    @objc func testTepmlateMethod() {
        self.test.run()
        assert("setUp testMethod tearDown " == self.test.log)
    }
    
    @objc func testResult() {
        let result = self.test.run()
        assert("1 run, 0 failed" == result.summary)
    }
    
    @objc func testFailedresult() {
        test = WasRun("testBrokenMethod")
        let result = self.test.run()
        assert("1 run, 1 failed" == result.summary)
    }
    
    @objc func testFailedResultFormatting() {
        var result = TestResult()
        result.testStarted()
        result.testFailed()
        assert("1 run, 1 failed" == result.summary)
    }
}


TestCaseTest("testTepmlateMethod").run()
TestCaseTest("testResult").run()
TestCaseTest("testFailedresult").run()
TestCaseTest("testFailedResultFormatting").run()
