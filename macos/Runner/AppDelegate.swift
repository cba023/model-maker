import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @IBAction func openRespUrl(_ sender: Any) {
        if let url = URL(string: "https://gitlab.wekoi.cc/wtc/wl-client/model_maker") {
            NSWorkspace.shared.open(url)
        }
    }

}
