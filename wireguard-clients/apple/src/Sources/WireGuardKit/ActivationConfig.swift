// Copyright @ 2021 Ericom Software.  All Rights Reserved.

import Foundation

public struct ActivationConfig {
    public var host: String
    public var key: String
}

extension ActivationConfig: Equatable {
    public static func == (lhs: ActivationConfig, rhs: ActivationConfig) -> Bool {
        return lhs.host == rhs.host && lhs.key == rhs.key
    }
}

extension ActivationConfig: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(host)
    }
}
