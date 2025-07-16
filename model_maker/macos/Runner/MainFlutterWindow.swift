import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        let minWidth: CGFloat = 1200
        self.minSize = NSSize(width: minWidth, height: minWidth * 0.65)
        let flutterViewController = FlutterViewController()
        self.setContentSize(self.minSize)
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        
        RegisterGeneratedPlugins(registry: flutterViewController)
        
        super.awakeFromNib()
    }
}
