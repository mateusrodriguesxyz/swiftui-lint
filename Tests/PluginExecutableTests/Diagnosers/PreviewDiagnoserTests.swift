import XCTest
@testable import SwiftUILintExecutable

final class PreviewDiagnoserTests: DiagnoserTestCase<PreviewDiagnoser> {

    func testPreviewMisplaced() {

        let source = """
        struct ContentView: View {
                        
            var body: some View { }
            
            1️⃣#Preview {
                ContentView()
            }
            
        }
        """

        _test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "'Preview' should be declared at the top level outside 'ContentView'")
        
        XCTAssertEqual(diagnostics("1️⃣"), "'Preview' should be declared at the top level outside 'ContentView'")

        
    }
    
    func testPreviewMissingEnvironmentObject() {

        let source = """
        struct ContentView: View {
                        
            @Environment(Model1.self) var model1
            @EnvironmentObject var model2: Model2
            
            var body: some View { }
            
        }
        
        #Preview {
            ContentView()
        }
        """

        test(source)

        XCTAssertEqual(count, 2)

        XCTAssertEqual(diagnoser.diagnostics[0].message, "Insert object of type 'Model1' using 'environment' modifier")
        XCTAssertEqual(diagnoser.diagnostics[1].message, "Insert object of type 'Model2' using 'environmentObject' modifier")
    }
    
    func testPreviewWrongEnvironmentObject() {

        let source = """
        struct ContentView: View {
                        
            @Environment(Model1.self) var model1
            @EnvironmentObject var model2: Model2
            
            var body: some View { }
            
        }
        
        #Preview {
            ContentView()
                .environment(Model3())
                .environmentObject(Model4())
        }
        """

        test(source)

        XCTAssertEqual(count, 2)

        XCTAssertEqual(diagnoser.diagnostics[0].message, "Insert object of type 'Model1' using 'environment' modifier")
        XCTAssertEqual(diagnoser.diagnostics[1].message, "Insert object of type 'Model2' using 'environmentObject' modifier")
    }
    
    func testPreviewCorrectEnvironmentObject() {

        let source = """
        struct ContentView: View {
                        
            @Environment(Model1.self) var model1
            @EnvironmentObject var model2: Model2
            
            var body: some View { }
            
        }
        
        #Preview {
            ContentView()
                .environment(Model1())
                .environmentObject(Model2())
        }
        """

        test(source)

        XCTAssertEqual(count, 0)
        
    }
    
}
