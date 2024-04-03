//VisionMiniApp.swift

import SwiftUI


class AppDelegate: NSObject, NSApplicationDelegate {
    var isWindowHidden = false // 添加这个变量来跟踪窗口是否隐藏
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设置窗口默认悬浮
        if let window = NSApp.windows.first {
            window.level = .floating
        }
    }
}

//extension AppDelegate {
//    static var shared: AppDelegate? {
//        return NSApp.delegate as? AppDelegate
//    }
//
//    func hideWindowToRight() {
//        guard let window = NSApp.keyWindow else { return }
//        var frame = window.frame
//        frame.origin.x = NSScreen.main!.frame.width - 10 // 保留10像素作为"把手"
//        NSApp.keyWindow?.setFrame(frame, display: true, animate: true)
//        // 设置一个标志，表示窗口处于隐藏状态
//        isWindowHidden = true
//    }
//
//    func showWindowFromRight() {
//        guard let window = NSApp.keyWindow else { return }
//        var frame = window.frame
//        frame.origin.x = NSScreen.main!.frame.width - frame.width
//        NSApp.keyWindow?.setFrame(frame, display: true, animate: true)
//        // 清除隐藏状态的标志
//        isWindowHidden = false
//    }
//}


@main
struct MainApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandGroup(after: .windowArrangement) {
                Button("Toggle Float") {
                    toggleWindowFloating()
                }
                .keyboardShortcut("f", modifiers: [.command,.shift])
            }
            CommandGroup(after: CommandGroupPlacement.appTermination) {
                // 刷新页面的命令
                Button("Refresh Page") {
                    NotificationCenter.default.post(name: .refreshWebView, object: nil)
//                    refreshWebView()
                }
                .keyboardShortcut("r", modifiers: [.command,.shift])
                
                // 更换网页地址的命令
                Button("Change URL") {
                    // 发送通知以显示覆盖层
                    NotificationCenter.default.post(name: .toggleOverlay, object: nil)
                }
                .keyboardShortcut("h", modifiers: [.command,.shift])
                
//                Button("Hide to Right") {
//                    AppDelegate.shared?.hideWindowToRight()
//                       }
//                       .keyboardShortcut(.rightArrow, modifiers: [.command])
//
//                       Button("Show from Right") {
//                           AppDelegate.shared?.showWindowFromRight()
//                       }
//                       .keyboardShortcut(.leftArrow, modifiers: [.command])
//                
            }
        }
        .windowStyle(HiddenTitleBarWindowStyle()) // 隐藏默认的标题栏样式
        
        
    }
    
    func toggleWindowFloating() {
        if let window = NSApp.keyWindow {
            if window.level == .normal {
                window.level = .floating
            } else {
                window.level = .normal
            }
        }
    }
    func refreshWebView() {
        // 刷新WebView的逻辑
        NotificationCenter.default.post(name: .refreshWebView, object: nil)
    }
    
    func changeWebViewURL(to urlString: String) {
        // 更换WebView网页地址的逻辑
        NotificationCenter.default.post(name: .changeWebViewURL, object: nil)
    }
}

// 定义通知名称
extension Notification.Name {
    static let toggleOverlay = Notification.Name("toggleOverlay")
    static let refreshWebView = Notification.Name("refreshWebView")
    static let changeWebViewURL = Notification.Name("changeWebViewURL")
}
