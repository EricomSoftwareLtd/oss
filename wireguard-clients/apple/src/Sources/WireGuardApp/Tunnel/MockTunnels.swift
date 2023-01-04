// Copyright @ 2021 Ericom Software.  All Rights Reserved.

import NetworkExtension

// Creates mock tunnels for the iOS Simulator.

#if targetEnvironment(simulator)
class MockTunnels {
    static let tunnelNames = [
        "mfa_demo"
    ]
    static let address = "10.201.0.8"
    static let dnsServers = ["8.8.8.8", "8.8.4.4"]
    static let endpoint = "zte-client-authentication-gateway.zerotrustedge.com:51820"
    static let allowedIPs = "0.0.0.0/0"

    static func createMockTunnels() -> [NETunnelProviderManager] {
        return tunnelNames.map { tunnelName -> NETunnelProviderManager in

            var interface = InterfaceConfiguration(privateKey: PrivateKey())
            interface.addresses = [IPAddressRange(from: String(format: address, Int.random(in: 1 ... 10), Int.random(in: 1 ... 254)))!]
            interface.dns = dnsServers.map { DNSServer(from: $0)! }

            var peer = PeerConfiguration(publicKey: PrivateKey().publicKey)
            peer.endpoint = Endpoint(from: endpoint)
            peer.allowedIPs = [IPAddressRange(from: allowedIPs)!]

            let tunnelConfiguration = TunnelConfiguration(
                name: tunnelName,
                interface: interface,
                peers: [peer],
                activationConfig: ActivationConfig(host: "zte-client-authentication.zerotrustedge.com:8444", key: "k2IMIxP3/g9OFj7flsRzmoqyVG22LNVWjm9R7cP5jCs="))

            let tunnelProviderManager = NETunnelProviderManager()
            tunnelProviderManager.protocolConfiguration = NETunnelProviderProtocol(tunnelConfiguration: tunnelConfiguration)
            tunnelProviderManager.localizedDescription = tunnelConfiguration.name
            tunnelProviderManager.isEnabled = true

            return tunnelProviderManager
        }
    }
}
#endif
