import Foundation

struct CategoryRow: Identifiable, Hashable {
    let id: Int64
    let name: String
    let icon: String
    let color: UInt32
    let budget: Int64?
    let parentId: Int64?
}
