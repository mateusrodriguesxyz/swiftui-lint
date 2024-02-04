import XCTest
@testable import PluginExecutable

class DiagnoserTestCase<T: Diagnoser>: XCTestCase {

    let diagnoser = T()

    var count: Int { Diagnostics.emitted.count }

    var diagnostic: Diagnostic { Diagnostics.emitted.first! }

    var minimumDeploymentVersion: Double = 9999

    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }

    func test(_ source: String) {
        let context = Context(source)
        context.minimumDeploymentVersion = minimumDeploymentVersion
        Diagnostics.clear()
        diagnoser.run(context: context)
    }
    
}
