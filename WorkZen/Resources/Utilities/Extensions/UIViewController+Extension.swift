import UIKit

extension UIViewController {

    func hideKeyboardWhenTappedAround() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc
    func dismissKeyboard() {
        view.endEditing(true)
    }

}
