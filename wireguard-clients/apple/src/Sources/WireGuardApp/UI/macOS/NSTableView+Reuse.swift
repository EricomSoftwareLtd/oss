// SPDX-License-Identifier: MIT
// Copyright @ 2021 Ericom Software.  All Rights Reserved.

import Cocoa

extension NSTableView {
    func dequeueReusableCell<T: NSView>() -> T {
        let identifier = NSUserInterfaceItemIdentifier(NSStringFromClass(T.self))
        if let cellView = makeView(withIdentifier: identifier, owner: self) {
            //swiftlint:disable:next force_cast
            return cellView as! T
        }
        let cellView = T()
        cellView.identifier = identifier
        return cellView
    }
}
