import SwiftUI

/// 应用主视图 - 包含「生成」和「扫描」两个标签页
struct ContentView: View {

    @StateObject private var generateVM = GenerateViewModel()
    @StateObject private var scanVM = ScanViewModel()

    var body: some View {
        TabView {
            GenerateView(viewModel: generateVM)
                .tabItem {
                    Label("生成", systemImage: "qrcode")
                }

            ScanView(viewModel: scanVM)
                .tabItem {
                    Label("扫描", systemImage: "camera.viewfinder")
                }
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
}
