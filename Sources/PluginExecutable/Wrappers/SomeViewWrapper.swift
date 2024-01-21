import SwiftSyntax

@dynamicMemberLookup
struct SomeViewWrapper {

    let member: any MemberWrapperProtocol

    var hasViewBuilderAttribute: Bool {
        return member.attributes.contains("@ViewBuilder")
    }

    var content: ViewBuilderContentWrapper {
        return ViewBuilderContentWrapper(member)
    }

    init?(_ member: any MemberWrapperProtocol) {
        if member.type == "some View" {
            self.member = member
        } else {
            return nil
        }
    }

    subscript<T>(dynamicMember keyPath: KeyPath<MemberWrapperProtocol, T>) -> T {
        member[keyPath: keyPath]
    }

}
