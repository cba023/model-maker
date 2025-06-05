import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        self.minSize = NSSize(width: 1200, height: 1200 * 0.65)
        let flutterViewController = FlutterViewController()
        self.setContentSize(self.minSize)
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        
        RegisterGeneratedPlugins(registry: flutterViewController)
        
        super.awakeFromNib()
    }
}
