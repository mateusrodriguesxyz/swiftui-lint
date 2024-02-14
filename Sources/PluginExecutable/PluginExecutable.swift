import ArgumentParser
import Foundation

@main
struct PluginExecutable: AsyncParsableCommand {
    
    @Argument()
    var pluginWorkDirectory: String = ""
    
    @Argument(parsing: .captureForPassthrough)
    var files: [String] = foodTruckAll
    
    func run() async throws {
        
        var cache: Cache?
        
        await measure("Cache Loading") {
            cache = loadedCache()
        }
        
        try await measure("PluginExecutable.run") {
            try await _run(cache: cache)
        }
    }
    
    func _run(cache: Cache?) async throws {
        
        if let cache {
            print("warning: Types: \(cache.types.count)")
        }
        
        let diagnosers: [any Diagnoser] = [
            ViewBuilderCountDiagnoser(),
            MissingDotModifierDiagnoser(),
            ImageDiagnoser(),
            ControlLabelDiagnoser(),
            ToolbarDiagnoser(),
            ContainerDiagnoser(),
            ListDiagnoser(),
            SheetDiagnoser(),
            ScrollableDiagnoser(),
            PropertyWrapperDiagnoser(),
            NavigationDiagnoser(),
        ]
        
        //        if let cache, files.allSatisfy({ cache.fileHasChanges($0) == false }) {
        //            let diagnostics = cache.diagnostics.values.flatMap({ $0 })
        //            try emit(diagnostics)
        //            return
        //        }
        
        let context = Context(files: files, cache: cache)
        
        //        print("warning: Changed Files: \(context.files.filter(\.hasChanges).count)")
        
        let diagnostics = await context.run(diagnosers)
        
        try await measure("Caching") {
            try await updateCache(context, diagnostics: diagnostics)
        }
        
        
        try emit(diagnostics)
        
    }
    
    func emit(_ diagnostics: [Diagnostic]) throws {
        for diagnostic in diagnostics {
            diagnostic()
        }
        if diagnostics.contains(where: { $0.kind == .error }) {
            throw "exit 1"
        }
    }
    
}

extension PluginExecutable {
    
    func loadedCache() -> Cache? {
        let cacheURL = URL(filePath: pluginWorkDirectory).appending(path: "cache.json")
        return try? JSONDecoder().decode(Cache.self, from: Data(contentsOf: cacheURL))
    }
    
    func updateCache(_ context: Context, diagnostics: [Diagnostic]) async throws {
        
        let cacheURL = URL(filePath: pluginWorkDirectory).appending(path: "cache.json")
        
        var cache = context.cache ?? .init()
        
        //        if cache.types.isEmpty {
        //            cache.types = context.files.flatMap { file in
        //                TypesDeclCollector(file).all
        //                    .map { node in
        //                        SwiftModelTypeDeclaration(node, file: file, context: context)
        //                    }
        //            }
        //        }
        
        for file in context.files {
            cache.modificationDates[file.path] = file.modificationDate
        }
        
        cache.diagnostics = [:]
        cache.destinations = context.destinations
        
        for diagnostic in diagnostics {
            let origin = diagnostic.origin
            if let diagnostics = cache.diagnostics[origin] {
                cache.diagnostics[origin] = diagnostics + [diagnostic]
            } else {
                cache.diagnostics[origin] = [diagnostic]
            }
        }
        
        let encoder = JSONEncoder()
        
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
        
        let data = try encoder.encode(cache)
        
        try data.write(to: cacheURL)
        
    }
    
}

extension Context {
    
    func run(_ diagnosers: [Diagnoser]) async -> [Diagnostic] {
        
        await withTaskGroup(of: Void.self) { group in
            diagnosers.forEach { diagnoser in
                group.addTask {
                    await measure("\(Swift.type(of: diagnoser))") {
                        diagnoser.run(context: self)
                    }
                }
            }
        }
        
        return diagnosers.flatMap(\.diagnostics)
        
    }
    
    //    func modelOnlyFiles() {
    //
    //        let modelOnlyFiles = files.filter { file in
    //            TypesDeclCollector(file).all.allSatisfy { node in
    //                if let inheritedTypes = node.inheritanceClause?.inheritedTypes {
    //                    return inheritedTypes.contains(where: { ["App", "View", "PreviewProvider"].contains($0.trimmedDescription) }) == false
    //                } else {
    //                    return true
    //                }
    //            }
    //        }
    //
    //        print("warning: Model Only Files: \(modelOnlyFiles.count)/\(files.count)")
    //
    //    }
    
}

func measure(_ label: String, work: () async throws -> Void) async rethrows {
    let elapsed = try await ContinuousClock().measure {
        try await work()
    }
    print("warning: \(label): \(elapsed)")
}

let foodTruckAll: [String] = [
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Donut/DonutGalleryGrid.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Donut/ShowTopDonutsIntentView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Truck/Cards/TruckOrdersCard.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Navigation/ContentView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/App.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Orders/OrderDetailView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Account/SwiftUIView2.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Truck/SocialFeedView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Orders/OrderCompleteView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/City/RecommendedParkingSpotCard.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Store/StoreSupportView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Donut/DonutEditor.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Truck/SalesHistoryChart.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Donut/ShowTopDonutsIntent.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Store/RefundView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Store/UnlockFeatureView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Truck/Cards/CardNavigationHeaderLabelStyle.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Truck/Cards/TruckDonutsCard.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Donut/DonutGallery.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Store/SocialFeedPlusSettings.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/General/FlowLayout.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Navigation/DetailColumn.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/General/WidthThresholdReader.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Account/SignUpView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/City/CityWeatherCard.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Store/SubscriptionStoreView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Truck/Cards/TruckSocialFeedCard.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Truck/SocialFeedContent.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Truck/Cards/TruckWeatherCard.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/City/DetailedMapView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Donut/SwiftUIView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/Widgets/TruckActivityAttributes.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/City/ParkingSpotShowcaseView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/City/CityView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Navigation/Sidebar.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Donut/TopFiveDonutsView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Orders/OrdersView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Truck/SalesHistoryView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Truck/TruckView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Donut/TopDonutSalesChart.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Orders/OrdersTable.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Truck/SocialFeedPostView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Truck/Cards/CardNavigationHeader.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Orders/OrderRow.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Account/SomeSwiftUIView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Account/AccountView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/App/Donut/TopFiveDonutsChart.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Package.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Order/Order.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Order/OrderGenerator.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Order/OrderSummary.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Truck.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/City/City.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/City/ParkingSpot.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Donut/DonutStackView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Donut/DonutView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Donut/DiagonalDonutStackLayout.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Donut/DonutRenderer.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Donut/DonutSales.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Donut/Ingredients/Glaze.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Donut/Ingredients/Dough.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Donut/Ingredients/Ingredient.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Donut/Ingredients/Topping.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Donut/FlavorProfile.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Donut/DonutBoxView.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Donut/Donut.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/General/TaskSeconds.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/General/Interpolation.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/General/Images.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Brand/BrandHeader.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Model/FoodTruckModel.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Account/User.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Account/AccountStore.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Store/StoreProductController.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Store/Subscription.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Store/StoreMessagesManager.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Store/StoreSubscriptionController.swift",
    "/Users/mateusrodrigues/Downloads/FoodTruckBuildingASwiftUIMultiplatformApp/FoodTruckKit/Sources/Store/StoreActor.swift"
]
