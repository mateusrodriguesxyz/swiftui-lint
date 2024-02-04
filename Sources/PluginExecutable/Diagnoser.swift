protocol Diagnoser {
    init()
    func run(context: Context)
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
            let diagnostics = Cache.default?.diagnostics(self, file: file)
            diagnostics?.forEach {
                Diagnostics.emit($0)
            }
        }

    }

}
