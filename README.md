
## Usage

Add **SwiftUI Diagnostics** as a package dependency to your project without linking any of the products.

Select the target you want to add it and open the `Build Phases inspector`.

Open `Run Build Tool Plug-ins` and select the `+` button.

Select `SwiftUIDiagnosticsPlugin` from the list and add it to the project.

## Diagnostics

### Missing Modifier Dot

```swift

var body: some View {
    Rectangle()
        padding() // ❌  Missing 'padding' leading dot
}

```

### Non-Grouped Views

```swift

var body: some View { // ⚠️ Use a container view to group 'Image' and 'Text'
    Image(systemName: "globe")
    Text("Hello, world!")
}

NavigationStack { // ⚠️ Use a container view to group 'Image' and 'Text'
    Image(systemName: "globe")
    Text("Hello, world!")
}


```

### Stack Child Count

Includes *VStack*, *HStack*, *ZStack*, *NavigationStack*

```swift

VStack { // ⚠️ 'VStack' has only one child; consider using 'Color' on its own
    Color.red
}

HStack { // ⚠️ 'HStack' has no children; consider removing it
    
}

```

### Control Label

Includes *Button*, *NavigationLink*, *Link* and *Menu*

```swift

NavigationLink {
    
} label: {
    Button("Button") { }
}

```

### Sheet Dismiss

```swift

struct A: View {

    @State private var isShowingSheet = true

    var body: some View {
        Button("B") {
            isShowingSheet = true
        }
        .sheet(isPresented: $isShowingSheet) {
            B(isPresented: $isShowingSheet)
        }
    }
    
}

struct B: View {

    @Binding var isPresented: Bool

    var body: some View {
        Button("Dismiss") {
            isPresented = false // ⚠️ Dismiss 'SheetContent' using environment 'DismissAction' instead
        }
    }
    
}

```

### Observable Object Initialization

```swift

@ObservedObject var model = Model() // ⚠️ ObservedObject should not be used to create the initial instance of an observable object; use 'StateObject' instead

```

### Missing Environment Object

```swift

struct A: View {

    @StateObject private var model = Model()

    var body: some View {
        B()
    }
    
}

struct B: View {

    @EnvironmentObject private var model: Model

    var body: some View {
        Text(verbatim: "\(model)") // ⚠️ Insert object of type 'Model' in environment with 'environmentObject' up in the hierarchy
    }
    
}

```

### Resizable Image

```swift

Image("...")
    .frame(width: 100, height: 100) // ⚠️ Missing 'resizable' modifier
    
Image("...")
    .scaledToFit() // ⚠️ Missing 'resizable' modifier
    
Image("...")
    .scaledToFill() // ⚠️ Missing 'resizable' modifier

```

## State

### State Access Control

```swift
struct ContentView: View {
    
    @State var username = "" // ⚠️ Variable 'username' should be declared as private to prevent unintentional memberwise initialization
    
    var body: some View {
        TextField("Username", text: $username)
    }
    
}
```

### State Mutation

```swift
struct ContentView: View {
    
    @State private var author = "Hamlet" // ⚠️ Variable 'author' was never mutated or used to create a binding; consider changing to 'let' constant
    
    var body: some View {
        Text(author)
    }
    
}
```

### State Class Value

```swift
class Model { }

struct ContentView: View {
    
    @State private var model = Model() // ⚠️ Mark 'Model' type with '@Observable' or use 'StateObject' instead
    
    var body: some View {
        Color.red
    }
    
}
```

## Navigation

### Misplaced Navigation Modifiers

```swift
struct ContentView: View {

    var body: some View {
        NavigationStack {
            Text("ContentView")
        }
        .navigationTitle("Title") // ⚠️ Misplaced 'navigationTitle' modifier; apply it to NavigationStack content instead
    }
    
}
```


### Missing NavigationStack

```swift
struct A: View {

    var body: some View {
        NavigationLink("B", destination: B()) // ⚠️ 'NavigationLink' only works within a 'NavigationStack' hierarchy
    }
    
}

struct B: View {

    var body: some View {
        NavigationLink("C", destination: C()) // ⚠️ 'NavigationLink' only works within a 'NavigationStack' hierarchy
    }
    
}

struct C: View {
        
    var body: some View {
        Text("C")
    }
    
}
```

### Nested NavigationStack

```swift
struct A: View {

    var body: some View {
        NavigationStack {
            NavigationLink("B", destination: B()) // ⚠️ 'B' should not contain a NavigationStack
        }
    }
    
}

struct B: View {

    var body: some View {
        NavigationStack {
            NavigationLink("C", destination: C())
        }
    }
    
}
```

###  Navigation Loop

```swift
struct A: View {

    var body: some View {
        NavigationStack {
            NavigationLink("B", destination: B())
        }
    }
    
}

struct B: View {
    
    var body: some View {
        NavigationLink("C", destination: C())
    }
    
}

struct C: View {
        
    var body: some View {
        VStack {
            NavigationLink("A", destination: A()) // ⚠️  To go back more than one level in the navigation stack, use NavigationStack 'init(path:root:)' to store the navigation state as a 'NavigationPath', pass it down the hierarchy and call 'removeLast(_:)'
            NavigationLink("B", destination: B()) // ⚠️ To navigate back to 'B' use environment 'DismissAction' instead
        }
    }
    
}
```

## List

### Misplaced List Modifiers

```swift
List) {
                
}
.listRowBackground(Color.red) // ⚠️ Misplaced 'listRowBackground' modifier; apply it to List rows instead
```

### Selection Type Mismatch

```swift

struct ContentView: View {

    @State private var selection: String? = ""

    private let values = [1, 2, 3, 4, 5]

    private let models: [Model] = [Model(), Model(), Model(), Model(), Model()]

    var body: some View {
        List(selection: $selection) {
        
            Text("0")
                .tag(0) // ⚠️ tag value '0' type 'Int' doesn't match 'selection' type 'String'
        
            ForEach(1..<5) { // ⚠️ 'ForEach' data element 'Int' doesn't match 'selection' type 'String'
                Text("\($0)")
            }
            
            ForEach([1, 2, 3, 4, 5], id: \.self) { ⚠️ 'ForEach' data element 'Int' doesn't match 'selection' type 'String'
                Text("\($0)")
            }
            
            ForEach(values, id: \.self) { ⚠️ 'ForEach' data element 'Int' doesn't match 'selection' type 'String'
                Text("\($0)")
            }
            
            ForEach(models) { // ⚠️ ForEach' data element 'Model' id type 'UUID' doesn't match 'selection' type 'String'
                Text("\($0.id)")
            }
            
            ForEach(models, id: \.name) { // ⚠️ ForEach' data element 'Model' member 'name' type 'String' doesn't match 'selection' type 'Int'
                Text("\($0.name)")
            }
            
        }
    }

}


```

## Picker

### Selection Type Mismatch


```swift

struct ContentView: View {
        
    @State private var selection: Set<Int> = []
    
    var body: some View {
        Picker("Picker", selection: $selection) { // ⚠️ 'Picker' doesn't support multiple selections
            ...
        }
    }
    
}


```

```swift

struct ContentView: View {
        
    @State private var selection: Int?
    
    private let values = [1, 2, 3, 4, 5]
    
    var body: some View {
        Picker("Picker", selection: $selection) {

            Text("None") // ⚠️ Apply 'tag' modifier with 'Int?' value to match 'selection' type
            
            Text("0")
                .tag("0") // ⚠️ tag value 'a' type 'String' doesn't match 'selection' type 'Int?'

            ForEach(1..<5) {
                Text("Row \($0)") // ⚠️ Apply 'tag' modifier with explicit Optional<Int> value to match 'selection' type 'Int?'
            }
            
            ForEach(["a", "b", "c"], id: \.self) { // ⚠️ 'ForEach' data element 'String' doesn't match 'selection' type 'Int?'
                Text("Value \($0)")
            }
                
        }
    }
    
}


```








