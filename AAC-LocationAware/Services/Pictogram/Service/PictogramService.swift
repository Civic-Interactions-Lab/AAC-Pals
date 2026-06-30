import UIKit

protocol PictogramService: Sendable {
    func fetchURL(for label: String, arasaacId: Int?) async -> URL?
    func fetchImage(for label: String, arasaacId: Int?) async -> UIImage?
}
