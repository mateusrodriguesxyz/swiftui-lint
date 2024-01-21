import SwiftSyntax

struct ImageDiagnoser: Diagnoser {

    func run(context: Context) {

        for view in context.views {

            guard view.contains("Image") else { continue }

            for image in ViewCallCollector(["Image"], from: view.decl).calls {

                if image.arguments.isEmpty {
                    continue
                }

                if image.arguments.contains(where: { $0.label?.text == "systemName" }) {
                    continue
                }

                for frame in ModifiersFinder(modifiers: ["frame", "scaledToFit"])(image) {

                    if let resizable = ModifiersFinder(modifiers: ["resizable"])(image).first, resizable.node.position < frame.node.position {
                        continue
                    }

                    Diagnostics.emit(.warning, message: "Missing 'resizable' modifier", node: frame.node, offset: -1, file: view.file)
                }

            }

        }

    }

}
