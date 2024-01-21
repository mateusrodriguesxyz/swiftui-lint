import XCTest
@testable import SwiftUILintExecutable

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
        let context = try! _unsafeWait {
            await Context(FileWrapper(source.replacingOccurrences(of: "⚠️", with: "")))
        }
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

fileprivate class Box<ResultType> {
    var result: Result<ResultType, Error>? = nil
}

func _unsafeWait<ResultType>(_ f: @escaping () async throws -> ResultType) throws -> ResultType {
    let box = Box<ResultType>()
    let sema = DispatchSemaphore(value: 0)
    Task {
        do {
            let val = try await f()
            box.result = .success(val)
        } catch {
            box.result = .failure(error)
        }
        sema.signal()
    }
    sema.wait()
    return try box.result!.get()
}
