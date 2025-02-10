import Foundation
import RealmSwift

final class Task: Object {
    @Persisted(primaryKey: true) var id = UUID()
    @Persisted var name: String = ""
    @Persisted var desc: String = ""
    @Persisted var isCompleted: Bool = false
    @Persisted var importance: ImportanceLevel = .low
    @Persisted var time: Date = Date()
    @Persisted var color: TaskColor = .lightBlue
    @Persisted var category: TaskCategory = .personal
    
    convenience init(
        id: UUID = UUID(),
        name: String = "",
        description: String = "",
        isCompleted: Bool = false,
        importance: ImportanceLevel = .low,
        time: Date = Date(),
        color: TaskColor = .lightBlue,
        category: TaskCategory = .personal
    ) {
        self.init()
        self.id = id
        self.name = name
        self.desc = description
        self.isCompleted = isCompleted
        self.importance = importance
        self.time = time
        self.color = color
        self.category = category
    }
    
    // Add Index Proprerties: Tối ưu hiệu xuất tìm kiếm khi thêm chỉ mục
    override class func indexedProperties() -> [String] {
        ["name", "category"]
    }
}

// Enum cho cấp độ quan trọng
enum ImportanceLevel: String, PersistableEnum, CaseIterable {
    case low, medium, high
}

// Enum cho màu sắc
enum TaskColor: String, PersistableEnum, CaseIterable {
    case lightRed = "LightRed"
    case lightGreen = "LightGreen"
    case lightBlue = "LightBlue"
    case lightYellow = "LightYellow"
}

// Enum cho danh mục
enum TaskCategory: String, PersistableEnum, CaseIterable {
    case work, personal, study
}
