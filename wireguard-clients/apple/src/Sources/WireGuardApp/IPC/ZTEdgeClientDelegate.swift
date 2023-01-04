import Foundation

protocol TunnelServiceDelegate: AnyObject {
    func tunnelManagerCreated()
    func tunnelManagerCreationFailed(error: TunnelsManagerError)
}

class ZTEdgeClientDelegate: ConnectionDelegate {
    var tunnelsManager: TunnelsManager?

    init() {
        self.tunnelsManager = nil
        TunnelsManager.create { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            case .success(let tunnelsManager):
                self.tunnelsManager = tunnelsManager
                self.startIpcClient()
            }
        }
    }

    func connectionOpened(connection: ClientConnection) {
        print("connectionOpened")
    }

    func connectionClosed(connection: ClientConnection) {
        print("connectionClosed")
    }

    func connectionError(connection: ClientConnection, error: Error) {
        print("connectionError")
    }

    func connectionReceivedData(connection: ClientConnection, data: Data) {
        print("connectionReceivedData")

        let decoder = JSONDecoder()
        let message = try? decoder.decode(Message.self, from: data)

        switch message?.command {
        case Constants.getStatusCommandName:
            print("Handle \(Constants.getStatusCommandName) message")
            self.handleGetStatusMessage(connection: connection)
        case Constants.activateTunnelRequestCommand:
            print("Handle \(Constants.activateTunnelRequestCommand) message")
            let request = try? decoder.decode(ActivateTunnelRequest.self, from: data)
            if request == nil {
                print("Cannot parse \(Constants.activateTunnelRequestCommand) message")
                return
            }
            self.handleActivateTunnelMessage(request: request!, connection: connection)
        case Constants.deactivateTunnelRequestCommand:
            print("Handle \(Constants.deactivateTunnelRequestCommand) message")
            let request = try? decoder.decode(DeactivateTunnelRequest.self, from: data)
            if request == nil {
                print("Cannot parse \(Constants.deactivateTunnelRequestCommand) message")
                return
            }
            self.handleDeactivateTunnelMessage(request: request!, connection: connection)
        default:
            print("Error: unknown command receviced \(message?.command)")
        }
    }

    private func startIpcClient() {
        let userDefaults = UserDefaults.init(suiteName: "MS46CN7MD3.group.com.ericom.ztac")
        let port = userDefaults?.integer(forKey: "port")

        let client = Client(host: "127.0.0.1", port: UInt16(port!))
        client.connection.delegate = self
        client.start()
    }

    private func handleGetStatusMessage(connection: ClientConnection) {
        let messageAsObject = GetStatusResponse(command: Constants.getStatusResponseCommanVariableName, status: "ok")
        let encoder = JSONEncoder()
        do {
            let messageAsObjectData = try encoder.encode(messageAsObject)
            connection.send(data: messageAsObjectData)
        } catch {
            print(error.localizedDescription)
        }
    }

    private func handleActivateTunnelMessage(request: ActivateTunnelRequest, connection: ClientConnection) {
        guard let tunnelsManager = self.tunnelsManager else {
            print("On startTunnel: Tunnels manager was not initialized")
            return
        }

        var tunnelConfiguration: TunnelConfiguration
        do {
            tunnelConfiguration = try TunnelConfiguration(fromWgQuickConfig: request.config, called: request.tunnelName)
        } catch let error as WireGuardAppError {
            print(error)
            return
        } catch {
            fatalError()
        }

        if tunnelsManager.numberOfTunnels() > 0 {
            tunnelsManager.modify(
                tunnel: tunnelsManager.tunnel(at: 0),
                tunnelConfiguration: tunnelConfiguration,
                onDemandOption: ActivateOnDemandOption.off,
                completionHandler: { [weak self] error in
                    guard let self = self else { return }
                    if let error = error {
                        print("Error on tunnel modification \(error.localizedDescription)")
                        return
                    }

                    tunnelsManager.startActivation(of: tunnelsManager.tunnel(at: 0))
                })
        } else {
            tunnelsManager.add(tunnelConfiguration: tunnelConfiguration) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure:
                    print("Failed to add tunnel configuration: \(request.tunnelName)")
                case .success:
                    print("Tunnel configuration: \(request.tunnelName) added successfully")
                    guard let tunnel = tunnelsManager.tunnel(named: request.tunnelName) else {
                        print("There is no tunnels in manager with expected name: \(request.tunnelName)")
                        return
                    }
                        //                tunnelsManager.activationDelegate = self
                    tunnelsManager.startActivation(of: tunnel)
                }
            }
        }

    }

    private func handleDeactivateTunnelMessage(request: DeactivateTunnelRequest, connection: ClientConnection) {
        guard let tunnelsManager = self.tunnelsManager else {
            print("On deactivaion tunnel: Tunnels manager was not initialized")
            return
        }

        if tunnelsManager.numberOfTunnels() > 0 {
        }

        let tunnel = tunnelsManager.tunnel(at: tunnelsManager.numberOfTunnels() - 1)
        tunnelsManager.startDeactivation(of: tunnel)

        connection.stop()

    }

}
