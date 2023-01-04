// Copyright @ 2021 Ericom Software.  All Rights Reserved.

import UIKit

extension UITableViewCell {
    static var reuseIdentifier: String {
        return NSStringFromClass(self)
    }
}

extension UITableView {
    func register<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        //swiftlint:disable:next force_cast
        return dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
