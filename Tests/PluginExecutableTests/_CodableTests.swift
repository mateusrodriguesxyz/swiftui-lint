import XCTest
import SwiftParser
import SwiftSyntax
@testable import PluginExecutable

final class CodableTests: XCTestCase {

    func testCodable() async throws {

        let path = Bundle.module.url(forResource: "Donut", withExtension: nil)!.path()
        
        let context = Context(files: [path], cache: nil)
        
        let file = context.files[0]
        
        let model = context.types.structs[0]
        
        let codable = SwiftModelTypeDeclaration(model, file: file, context: context)
        
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//        
//        let data = try encoder.encode(codable)
//        
//        let json = String(data: data, encoding: .utf8)!
//        
//        print(json)
        
        XCTAssertEqual(codable.properties.count, 26)

    }
    
    func testEnvironmentObject() async throws {

        let path = Bundle.module.url(forResource: "ContentView", withExtension: nil)!.path()
        
        let context = Context(files: [path], cache: nil)
        
        let file = context.files[0]
        
        let view = context.views[0]
        
        let collector =  ModifierCollector(modifier: "environmentObject", view.node)
        
        let environmentObjectModifiers: [EnvironmentObjectModifierWrapper] = collector.matches.compactMap { match in
            
            guard 
                let object = match.expression?.trimmedDescription,
                let _property = view.property(named: object),
                let content = match.content
            else {
                return nil
            }

            let targets = DestinationCollector(content, context: context).destinations
            
            return EnvironmentObjectModifierWrapper(property: _property.name, targets: targets)
            
        }
        
        let codable = SwiftModelTypeDeclaration(view.node, file: file, context: context)
        
        print(codable)
        
        print(environmentObjectModifiers)
        

    }

}

struct EnvironmentObjectModifierWrapper: Codable {
    let property: String
    let targets: [String]
}
