protocol Diagnoser {
    func run(context: Context)
    func diagnose(_ view: ViewDeclWrapper)
}

extension Diagnoser {

    func run(context: Context) {
        print("warning: \(Self.self) - 'Diagnoser.\(#function)'")
        for view in context.views {
            diagnose(view)
        }
    }

}


protocol CachableDiagnoser: Diagnoser {
    func diagnose(_ view: ViewDeclWrapper)
}

extension CachableDiagnoser {

    func run(context: Context) {

        print("warning: 'CachableDiagnoser.\(#function)'")

        var unchangedFiles = Set<String>()

        for view in context.views {
            guard view.file.hasChanges else {
                unchangedFiles.insert(view.file.path)
                continue
            }
            diagnose(view)
        }

        for file in unchangedFiles {
            let diagnostics = Cache.default?.diagnostics(self, file: file)
            diagnostics?.forEach {
                Diagnostics.emit($0)
            }
        }

    }

}
