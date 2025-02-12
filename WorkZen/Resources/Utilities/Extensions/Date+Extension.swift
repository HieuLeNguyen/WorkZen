import Foundation

extension Date {
    
    // MARK: - Format type Date -> Day (ex: "9 Sunday")
    
    func toTitleFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "d EEEE"
        return dateFormatter.string(from: self)
    }
    
    // MARK: - Format type Date -> Time (ex: "10:20")
    
    func toTimeFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    // MARK: - Transfer type String -> Date (ex: "9 Sunday" -> Date)
    
    static func fromTitle(_ title: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "d EEEE"
        
        return formatter.date(from: title) ?? Date.distantPast
    }
}
