import XCTest
@testable import PluginExecutable

class DiagnoserTestCase<T: Diagnoser>: XCTestCase {

    let diagnoser = T()

    var count: Int { diagnoser.diagnostics.count }

    var diagnostic: Diagnostic { diagnoser.diagnostics.first! }

    var iOSDeploymentVersion: Double? = nil
    var macOSDeploymentVersion: Double? = nil

    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }

    func test(_ source: String) {
        diagnoser.diagnostics = []
        let context = Context(source)
        context.target.iOS = iOSDeploymentVersion
        context.target.macOS = macOSDeploymentVersion
        
//        for (name, paths) in context._paths {
//            print(name)
//            for path in paths {
//                print(path.description)
//            }
//            print("\n")
//        }
//        
//        print("-----------------------------------")
        
        diagnoser.run(context: context)
    }
    
}
