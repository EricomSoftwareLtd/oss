import Cocoa
import CoreServices

class CustomURLSchemeHandler: NSObject {

    static let shared = CustomURLSchemeHandler()

    public typealias EventHandler = (URL) -> Void
    private var eventHandler: EventHandler?

    func register(handler: @escaping EventHandler) {
        self.eventHandler = handler
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(self.handleAppleEvent(event:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }

    func unregister() {
        NSAppleEventManager.shared().removeEventHandler(forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }

    @objc func handleAppleEvent(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        guard let appleEventDescription = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)) else {
            return
        }

        guard let handler = self.eventHandler else {
            return
        }

        guard let appleEventURLString = appleEventDescription.stringValue else {
            return
        }

        guard let URLdata = URL(string: appleEventURLString) else {
            return
        }

        handler(URLdata)
    }
}
