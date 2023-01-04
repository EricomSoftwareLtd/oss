// Copyright @ 2021 Ericom Software.  All Rights Reserved.

import Foundation

func tr(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

func tr(format: String, _ arguments: CVarArg...) -> String {
    return String(format: NSLocalizedString(format, comment: ""), arguments: arguments)
}
