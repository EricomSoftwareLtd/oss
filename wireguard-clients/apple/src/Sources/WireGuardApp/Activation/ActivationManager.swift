// Copyright @ 2021 Ericom Software.  All Rights Reserved.

import Foundation
#if SWIFT_PACKAGE
    import libMFA
#endif

#if os(iOS)
    import UIKit
#endif

#if os(macOS)
    import Cocoa
#endif

class ActivationManager {

    static let activationScheme = "zte"

    private var host = ""
    private var pendingActivationTunnelName = ""
    private let queue = DispatchQueue(label: "com.ericom.ztac.atomic")

    func getActivationData(config: ActivationConfig, tunnelName: String, completion: @escaping (APIError) -> Void) {

        DispatchQueue.global(qos: .userInteractive).async {
            self.pendingActivationTunnelName = tunnelName
            self.host = config.host
            wg_log(.info, message: "Starting activation....\n")

            let result = libMFA.getActivationData(config.host, config.key, ActivationManager.activationScheme) { url in
                guard let url = url else { return }
                let swiftString = String(cString: url).trimmingCharacters(in: .newlines)

                DispatchQueue.main.async {
                    if let authentictationUrl = URL(string: swiftString) {

                        #if os(iOS)
                        UIApplication.shared.open(authentictationUrl)
                        #elseif os(macOS)
                        NSWorkspace.shared.open(authentictationUrl)
                        #endif
                    }
                }
            }

            DispatchQueue.main.async {
                completion(APIError(rawValue: result) ?? APIError.serverError)
            }
        }
    }

    func activationPendingTunnelName() -> String {
        return self.pendingActivationTunnelName
    }

    func verifyActivationData(url: URL, completion: @escaping (APIError) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {

            let result = libMFA.verifyActivationResult(self.host, ActivationManager.activationScheme, url.absoluteString)

            DispatchQueue.main.async {
                completion(APIError(rawValue: result) ?? APIError.serverError)
            }
        }
    }

    /*

     libMFA go library codes
     const (
     NoErrors              = 0
     UserLoggedIn          = 1
     NoActivationNeeded    = 2
     WebActivationRequired = 3
     CannotStartListener   = -1
     CannotOpenBrowser     = -2
     ServerError           = -3
     InvalidCredentials    = -4
     )
     */
    enum APIError: Int32 {
        case noError = 0
        case noActivationNeeded = 2
        case webActivationRequired = 3
        case noInternet = -1
        case httpError = -2
        case serverError = -3
        case invalidCredentials = -4

        public var errorCode: Int {
            switch self {
            case .noError: return 0
            case .noActivationNeeded: return 2
            case .webActivationRequired: return 3
            case .noInternet: return -1
            case .httpError: return -2
            case .serverError: return -3
            case .invalidCredentials: return -4
            }
        }

        var description: String {
            switch self {
            case .noInternet:
                return "There is no internet connection."
            case .httpError:
                return "The call failed with HTTP code \(errorCode)."
            case .serverError:
                return "Server error."
            case .noError:
                return "OK"
            case .invalidCredentials:
                return "Failed to authenticate with conf file"
            case .noActivationNeeded:
                return ""
            case .webActivationRequired:
                return ""
            }
        }
    }
}
