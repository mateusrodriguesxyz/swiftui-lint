import Foundation

extension String {

    func contains(anyOf strings: String...) -> Bool {
        return strings.contains { contains($0) }
    }
    
    func contains(anyOf strings: some Sequence<String>) -> Bool {
        return strings.contains { contains($0) }
    }
    
    func `is`(anyOf values: Self...) -> Bool {
        values.contains(self)
    }

}
