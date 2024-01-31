
import SwiftUI

struct A {

    static var value1 = A()

}

extension A {

    static var value2 = A()

}

extension A {

    static var value3 = A.value2

}

extension A {

    static var all = [value1, value2, value3]

}

struct B: View {

//    let value1 = A.value1
//    let value2 = A.value2
//    let value3 = A.value3

    let value = A.all

    var body: some View {
        EmptyView()
    }

}
