import SwiftUI

/// 「生成」标签页 - 文本转二维码
struct GenerateView: View {

    @ObservedObject var viewModel: GenerateViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 输入区域
                    inputSection

                    // 二维码显示区域
                    qrCodeSection

                    // 操作按钮
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("生成二维码")
            .background(Color(.systemGroupedBackground))
            .toast(message: $viewModel.toastMessage)
        }
    }

    // MARK: - 输入区域

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("输入文本")
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                TextField("请输入要生成二维码的文本...", text: $viewModel.inputText)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .submitLabel(.done)

                if !viewModel.inputText.isEmpty {
                    Button(action: viewModel.clearInput) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 二维码显示区域

    @ViewBuilder
    private var qrCodeSection: some View {
        if let image = viewModel.qrCodeImage {
            VStack(spacing: 12) {
                Image(uiImage: image)
                    .interpolation(.none)       // 关键：保持像素清晰，不模糊
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)

                Text(viewModel.inputText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        } else if viewModel.isGenerating {
            ProgressView()
                .frame(height: 250)
        } else {
            // 空状态占位
            VStack(spacing: 12) {
                Image(systemName: "qrcode")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary.opacity(0.4))
                Text("输入上方文本即可生成二维码")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 250)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 操作按钮

    private var actionButtons: some View {
        HStack(spacing: 20) {
            Button(action: viewModel.saveToPhotoLibrary) {
                Label("保存到相册", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.qrCodeImage == nil)
        }
    }
}

#Preview {
    GenerateView(viewModel: GenerateViewModel())
}
