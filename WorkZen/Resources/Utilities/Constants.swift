import UIKit

public let sb = UIStoryboard(name: "Main", bundle: .main)

// Các chế độ xem của HomeVC
enum ViewMode: String {
    case day = "Day"
    case week = "Week"
    case month = "Month"
}
