import XCTest
@testable import PluginExecutable

class DiagnoserTestCase<T: Diagnoser>: XCTestCase {

    let diagnoser = T()

    var count: Int { Diagnostics.emitted.count }

    var diagnostic: Diagnostic { Diagnostics.emitted.first! }

    func test(_ source: String) {
        let context = Context(source)
        Diagnostics.clear()
        diagnoser.run(context: context)
    }
    
}
