import SwiftUI
import PhotosUI
import VisionKit

/// 「扫描」标签页 - 扫码 & 图片识别
struct ScanView: View {

    @ObservedObject var viewModel: ScanViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 扫描入口
                    scanEntrySection

                    // 识别结果
                    resultSection
                }
                .padding()
            }
            .navigationTitle("扫描二维码")
            .background(Color(.systemGroupedBackground))
            .toast(message: $viewModel.toastMessage)
            // 相册选择器
            .photosPicker(
                isPresented: $viewModel.isShowingImagePicker,
                selection: $selectedPhotoItem,
                matching: .images
            )
            // 相机扫描器（iOS 16+）
            .sheet(isPresented: $viewModel.isShowingScanner) {
                DataScannerView { text in
                    viewModel.handleScanResult(text)
                }
            }
            // 处理相册选取（iOS 16 兼容）
            .onChange(of: selectedPhotoItem) { newItem in
                handlePhotoPickerItem(newItem)
            }
        }
    }

    // MARK: - State

    @State private var selectedPhotoItem: PhotosPickerItem?

    // MARK: - 扫描入口

    private var scanEntrySection: some View {
        VStack(spacing: 16) {
            // 相机扫码
            Button(action: { viewModel.isShowingScanner = true }) {
                Label("相机扫码", systemImage: "camera.viewfinder")
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            // 相册识别
            Button(action: { viewModel.isShowingImagePicker = true }) {
                Label("从相册选取", systemImage: "photo.on.rectangle")
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 结果展示

    @ViewBuilder
    private var resultSection: some View {
        if let text = viewModel.scannedText, !text.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Label("识别结果", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundColor(.green)

                Text(text)
                    .font(.body)
                    .textSelection(.enabled)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                HStack(spacing: 16) {
                    Button(action: viewModel.copyToClipboard) {
                        Label("复制", systemImage: "doc.on.doc")
                    }
                    .buttonStyle(.bordered)

                    Button(action: viewModel.clearResult) {
                        Label("清除", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else if viewModel.isRecognizing {
            VStack(spacing: 12) {
                ProgressView()
                Text("识别中...")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        } else {
            // 空结果占位
            VStack(spacing: 12) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary.opacity(0.4))
                Text("使用相机扫码或从相册选取图片")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 相册选择处理

    private func handlePhotoPickerItem(_ item: PhotosPickerItem?) {
        guard let item else { return }

        Task {
            viewModel.isRecognizing = true
            viewModel.isShowingImagePicker = false

            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data)
            else {
                viewModel.isRecognizing = false
                viewModel.toastMessage = "无法加载图片"
                return
            }

            viewModel.handleImageRecognition(image)
        }
    }
}

// MARK: - DataScannerView (iOS 16+ 相机扫码)

@available(iOS 16.0, *)
struct DataScannerView: UIViewControllerRepresentable {

    let onScan: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .accurate,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        try? uiViewController.startScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onScan: (String) -> Void

        init(onScan: @escaping (String) -> Void) {
            self.onScan = onScan
        }

        func dataScanner(_ dataScanner: DataScannerViewController,
                         didTapOn item: RecognizedItem) {
            switch item {
            case .barcode(let barcode):
                if let text = barcode.payloadStringValue {
                    onScan(text)
                }
            default:
                break
            }
        }
    }
}

#Preview {
    ScanView(viewModel: ScanViewModel())
}
