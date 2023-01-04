import Foundation

struct Message: Codable {
    var command: String

    enum CodingKeys: String, CodingKey {
        case command = "Command"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.command = try container.decode(String.self, forKey: .command)
    }
}

struct GetStatusResponse: Encodable {
    var command: String
    var status: String

    enum CodingKeys: String, CodingKey {
        case command = "Command"
        case status = "Status"
    }

    init (command: String, status: String) {
        self.command = command
        self.status = status
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(command, forKey: .command)
        try container.encode(status, forKey: .status)
    }
}

struct ActivateTunnelRequest: Codable {
    var command: String
    var tunnelName: String
    var config: String
    var userName: String

    enum CodingKeys: String, CodingKey {
        case command = "Command"
        case tunnelName = "TunnelName"
        case config = "Config"
        case userName = "User"
    }

    init (command: String, tunnelName: String, config: String, userName: String) {
        self.command = command
        self.tunnelName = tunnelName
        self.config = config
        self.userName = userName
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.command = try container.decode(String.self, forKey: .command)
        self.tunnelName = try container.decode(String.self, forKey: .tunnelName)
        self.config = try container.decode(String.self, forKey: .config)
        self.userName = try container.decode(String.self, forKey: .userName)
    }
}

struct DeactivateTunnelRequest: Codable {
    var command: String
    var tunnelName: String
    var userName: String

    enum CodingKeys: String, CodingKey {
        case command = "Command"
        case tunnelName = "TunnelName"
        case userName = "User"
    }

    init (command: String, tunnelName: String, userName: String) {
        self.command = command
        self.tunnelName = tunnelName
        self.userName = userName
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.command = try container.decode(String.self, forKey: .command)
        self.tunnelName = try container.decode(String.self, forKey: .tunnelName)
        self.userName = try container.decode(String.self, forKey: .userName)
    }
}

