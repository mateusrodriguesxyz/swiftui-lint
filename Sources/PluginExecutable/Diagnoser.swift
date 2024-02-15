import SwiftSyntax

protocol Diagnoser: AnyObject {
    init()
    var diagnostics: [Diagnostic] { get set }
    func run(context: Context)
}

extension Diagnoser {
    
    func allFilesUnchanged(_ context: Context) -> Bool {
        if context.views.allSatisfy({ $0.file.hasChanges == false }) {
            for file in context.files {
                let diagnostics = context.cache?.diagnostics(self, file: file.path)
                diagnostics?.forEach {
                    emit($0)
                }
            }
            return true
        } else {
            return false
        }
    }
    
}

protocol CachableDiagnoser: Diagnoser {
    func diagnose(_ view: ViewDeclWrapper)
}

extension CachableDiagnoser {

    func run(context: Context) {

        var unchangedFiles = Set<String>()

        for view in context.views {
            guard view.file.hasChanges else {
                unchangedFiles.insert(view.file.path)
                continue
            }
            diagnose(view)
        }

//        print("warning: \(Self.self) - 'CachableDiagnoser.\(#function)' - unchangedFiles: \(unchangedFiles.count)")

        for file in unchangedFiles {
            let diagnostics = context.cache?.diagnostics(self, file: file)
            diagnostics?.forEach {
                emit($0)
            }
        }

    }

}

extension Diagnoser {
    
    func emit(_ diagnostic: Diagnostic) {
        diagnostics.append(diagnostic)
    }
    
    func warning(_ message: String, node: SyntaxProtocol, offset: Int = 0, file: FileWrapper) {
        let diagnostic = Diagnostic(origin: String(describing: type(of: self)), kind: .warning, location: file.location(of: node), offset: offset, message: message)
        diagnostics.append(diagnostic)
    }
    
    func error(_ message: String, node: SyntaxProtocol, offset: Int = 0, file: FileWrapper) {
        let diagnostic = Diagnostic(origin: String(describing: type(of: self)), kind: .error, location: file.location(of: node), offset: offset, message: message)
        diagnostics.append(diagnostic)
    }
    
    func warning(_ message: String, offset: Int = 0, location: SourceLocation) {
        let diagnostic = Diagnostic(origin: String(describing: type(of: self)), kind: .warning, location: location, offset: offset, message: message)
        diagnostics.append(diagnostic)
    }
    
    func error(_ message: String, offset: Int = 0, location: SourceLocation) {
        let diagnostic = Diagnostic(origin: String(describing: type(of: self)), kind: .error, location: location, offset: offset, message: message)
        diagnostics.append(diagnostic)
    }
    
    
}
