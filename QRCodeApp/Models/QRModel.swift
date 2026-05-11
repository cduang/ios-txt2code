import Foundation
import UIKit

/// 二维码生成/识别结果的数据模型
struct QRCodeResult: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let timestamp: Date = Date()
}
