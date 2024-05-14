import Foundation

extension String {

    func `is`(anyOf values: Self...) -> Bool {
        values.contains(self)
    }
    
    func contains(anyOf strings: String...) -> Bool {
        return strings.contains { contains($0) }
    }
    
    func contains(anyOf strings: some Sequence<String>) -> Bool {
        return strings.contains { contains($0) }
    }

}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
