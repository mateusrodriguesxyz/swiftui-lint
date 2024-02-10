import XCTest
@testable import PluginExecutable

class DiagnoserTestCase<T: Diagnoser>: XCTestCase {

    let diagnoser = T()

    var count: Int { diagnoser.diagnostics.count }

    var diagnostic: Diagnostic { diagnoser.diagnostics.first! }

    var iOSDeploymentVersion: Double = 9999

    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }

    func test(_ source: String) {
        let context = Context(source)
        context.target.iOS = iOSDeploymentVersion
        diagnoser.run(context: context)
    }
    
}
