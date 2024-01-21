import SwiftSyntax

extension [ViewDeclWrapper] {

    func run(_ block: @escaping (ViewDeclWrapper) -> Void) async {
        await withTaskGroup(of: Void.self) { group in
            for each in self {
                group.addTask {
                    block(each)
                }
            }
        }
    }

}

struct _CombinedDiagnoser: Diagnoser {

    func run(context: Context) {

        for view in context.views {

            let matches = AnyViewCallCollector(kinds: ["Image", "Button", "NavigationLink"], node: view.decl).matches

            if let images = matches["Image"] {

                for image in images {

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

            if let controls = matches["Button"] + matches["NavigationLink"] {
                

                for control in controls {
                    for innerControl in ViewCallCollector(["Button", "NavigationLink"], from: control.additionalTrailingClosures).calls {
                        Diagnostics.emit(.warning, message: "'\(innerControl)' should not be placed inside '\(control)' label", node: innerControl, file: view.file)
                    }
                }

            }

        }

    }

}

extension [FunctionCallExprSyntax]? {

    static func + (left: Self, right: Self) -> [FunctionCallExprSyntax]? {
        var result = [FunctionCallExprSyntax]()
        if let left {
            result.append(contentsOf: left)
        }
        if let right {
            result.append(contentsOf: right)
        }
        if result.isEmpty {
            return nil
        } else {
            return result
        }
    }

}
