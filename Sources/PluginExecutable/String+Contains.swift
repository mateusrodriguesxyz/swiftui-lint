import Foundation

extension String {

    func contains(anyOf strings: some Sequence<String>) -> Bool {
        return strings.contains { contains($0) }
    }

}
