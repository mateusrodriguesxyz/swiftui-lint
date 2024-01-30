import SwiftSyntax

struct MissingDotModifierDiagnoser: CachableDiagnoser {

    func diagnose(_ view: ViewDeclWrapper) {

        // MARK: Missing Modifier Leading Dot

        for call in BrokenModifierCallCollector(view.node).calls {
            Diagnostics.emit(self, .error, message: "Missing '\(call.baseName.text)' leading dot", node: call, file: view.file)
        }

    }

}
