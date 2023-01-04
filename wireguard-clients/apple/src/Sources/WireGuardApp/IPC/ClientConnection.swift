import Foundation
import Network

protocol ConnectionDelegate: AnyObject {
    func connectionOpened(connection: ClientConnection)
    func connectionClosed(connection: ClientConnection)
    func connectionError(connection: ClientConnection, error: Error)
    func connectionReceivedData(connection: ClientConnection, data: Data)
}

@available(macOS 10.14, *)
class ClientConnection {

    weak var delegate: ConnectionDelegate?
    let  nwConnection: NWConnection
    let queue = DispatchQueue(label: "Client connection Q")

    init(nwConnection: NWConnection) {
        self.nwConnection = nwConnection
    }

    var didStopCallback: ((Error?) -> Void)? = nil

    func start() {
        print("connection will start")
        nwConnection.stateUpdateHandler = stateDidChange(to:)
        setupReceive()
        nwConnection.start(queue: queue)
    }

    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            connectionDidFail(error: error)
        case .ready:
            print("Client connection ready")
            self.delegate?.connectionOpened(connection: self)
        case .failed(let error):
            connectionDidFail(error: error)
        default:
            break
        }
    }

    private func setupReceive() {
        nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
            if let data = data, !data.isEmpty {
                self.delegate?.connectionReceivedData(connection: self, data: data)
                let message = String(data: data, encoding: .utf8)
                print("connection did receive, data: \(data as NSData) string: \(message ?? "-" )")
            }
            if isComplete {
                self.connectionDidEnd()
            } else if let error = error {
                self.connectionDidFail(error: error)
            } else {
                self.setupReceive()
            }
        }
    }

    func send(data: Data) {
        nwConnection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                self.connectionDidFail(error: error)
                return
            }
            print("connection did send, data: \(data as NSData)")
        }))
    }

    func stop() {
        print("connection will stop")
        stop(error: nil)
    }

    private func connectionDidFail(error: Error) {
        print("connection did fail, error: \(error)")
        self.delegate?.connectionError(connection: self, error: error)
        self.stop(error: error)
    }

    private func connectionDidEnd() {
        print("connection did end")
        self.stop(error: nil)
    }

    private func stop(error: Error?) {
        self.delegate?.connectionClosed(connection: self)
        self.nwConnection.stateUpdateHandler = nil
        self.nwConnection.cancel()

        if let didStopCallback = self.didStopCallback {
            self.didStopCallback = nil
            didStopCallback(error)
        }
    }
}
