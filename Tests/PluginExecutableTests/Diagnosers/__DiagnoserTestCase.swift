import XCTest
@testable import SwiftUILintExecutable

class DiagnoserTestCase<T: Diagnoser>: XCTestCase {

    let diagnoser = T()

    var count: Int { diagnoser.diagnostics.count }

    var diagnostic: Diagnostic {
        diagnoser.diagnostics.first(where: { $0.location.offset == offsets["1️⃣"] }) ?? Diagnostic(origin: "", kind: .warning, location: .init(line: 0, column: 0, offset: 0, file: ""), offset: 0, message: "")
    }

    var iOSDeploymentVersion: Double? = nil
    var macOSDeploymentVersion: Double? = nil
    
    private var offsets: [Character: Int] = [:]

    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }
    
    func test(_ source: String) {
        diagnoser.diagnostics = []
        for (offset, marker) in ["1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣"].compactMap(\.first).enumerated() {
            if let index = source.firstIndex(of: marker) {
                self.offsets[marker] = index.utf16Offset(in: source) - (3*offset)
            }
        }
        
        let source = source
            .replacingOccurrences(of: "1️⃣", with: "")
            .replacingOccurrences(of: "2️⃣", with: "")
            .replacingOccurrences(of: "3️⃣", with: "")
            .replacingOccurrences(of: "4️⃣", with: "")
            .replacingOccurrences(of: "5️⃣", with: "")
        let context = try! _unsafeWait {
            await Context(FileWrapper(source))
        }
        context.target.iOS = iOSDeploymentVersion
        context.target.macOS = macOSDeploymentVersion
        
        diagnoser.run(context: context)
    }
    
    func diagnostics(_ marker: Character) -> String? {
        diagnoser.diagnostics.first(where: { $0.location.offset == offsets[marker] })?.message
    }
    
}

fileprivate class Box<ResultType> {
    var result: Result<ResultType, Error>? = nil
}

func _unsafeWait<ResultType>(_ block: @escaping () async -> ResultType) throws -> ResultType {
    let box = Box<ResultType>()
    let sema = DispatchSemaphore(value: 0)
    Task {
        box.result = .success(await block())
        sema.signal()
    }
    sema.wait()
    return try box.result!.get()
}
