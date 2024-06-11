import XCTest
@testable import SwiftUILintExecutable

final class SearchDiagnoserTests: DiagnoserTestCase<SearchDiagnoser> {

    func testSearchScope() {

        let source = """
        
        enum ProductScope {
            case fruit
            case vegetable
        }
        
        struct ContentView: View {
        
            @State private var scope: ProductScope = .fruit
        
            var body: some View {
                ProductList()
                    .searchScopes($scope) {
                        Text("Fruit")
                            .tag(ProductScope.fruit)
                        1️⃣Text("Vegetable")
                    }
            }
        }
        """

        test(source)

        XCTAssertEqual(count, 1)

        XCTAssertEqual(diagnostic.message, "Apply 'tag' modifier with 'ProductScope' value to match 'scope' type")

    }
}
