// SPDX-License-Identifier: MIT
// Copyright © 2018-2020 WireGuard LLC. All Rights Reserved.

import Foundation

public final class TunnelConfiguration {

    // Defines name of the root section and key-value pairs name
    struct ConfigSection {
        static let root  = "Config"
        static let rootParser = "[config]"
        static let host = "host"
        static let key = "key"
    }

    public var name: String?
    public var interface: InterfaceConfiguration
    public let peers: [PeerConfiguration]
    public var activationConfig: ActivationConfig?

    public init(name: String?, interface: InterfaceConfiguration, peers: [PeerConfiguration], activationConfig: ActivationConfig?) {
        self.interface = interface
        self.peers = peers
        self.name = name
        self.activationConfig = activationConfig

        let peerPublicKeysArray = peers.map { $0.publicKey }
        let peerPublicKeysSet = Set<PublicKey>(peerPublicKeysArray)
        if peerPublicKeysArray.count != peerPublicKeysSet.count {
            fatalError("Two or more peers cannot have the same public key")
        }
    }
}

extension TunnelConfiguration: Equatable {
    public static func == (lhs: TunnelConfiguration, rhs: TunnelConfiguration) -> Bool {
        return lhs.name == rhs.name &&
            lhs.interface == rhs.interface &&
            Set(lhs.peers) == Set(rhs.peers)
    }
}
