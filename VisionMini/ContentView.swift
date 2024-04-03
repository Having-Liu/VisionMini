//ContentView.swift

import SwiftUI
import WebKit

struct ContentView: View {
    //    @State private var webView: WKWebView = WKWebView()
    @State private var urlString: String = ""
    @State private var inputURLString: String = ""
    @State private var webViewKey = UUID() // 用于重新加载 WebView 的关键状态
    @State private var showOverlay = false
    @State private var showWebView = false // 控制 WebView 是否显示的状态
    @State private var isFirstLoad = true
    @State private var historyURLs: [String] = []
    @State private var isActive: Bool = false
    
    // 添加一个属性来跟踪是否应该自动隐藏窗口
       @State private var autoHideEnabled = false
    
    // 保存 isFirstLoad 状态到 UserDefaults
    private func saveIsFirstLoadState() {
        UserDefaults.standard.set(isFirstLoad, forKey: "isFirstLoad")
    }
    
    // 从 UserDefaults 加载 isFirstLoad 状态
    private func loadIsFirstLoadState() {
        isFirstLoad = UserDefaults.standard.bool(forKey: "isFirstLoad")
    }
    
    
    // 保存链接历史记录到 UserDefaults
    private func saveHistoryURLs() {
        UserDefaults.standard.set(historyURLs, forKey: "HistoryURLs")
        // 保存最后一次访问的链接
        if let lastURL = historyURLs.last {
            UserDefaults.standard.set(lastURL, forKey: "LastVisitedURL")
            //            UserDefaults.standard.synchronize() // 强制同步到磁盘
            //            print("保存成功，历史记录: \(savedHistoryURLs), 最后访问的URL: \(savedLastURL)")
        }
        if let savedHistoryURLs = UserDefaults.standard.array(forKey: "HistoryURLs") as? [String],
           let savedLastURL = UserDefaults.standard.string(forKey: "LastVisitedURL") {
            print("保存成功，历史记录: \(savedHistoryURLs), 最后访问的URL: \(savedLastURL)")
        } else {
            print("保存失败")
        }
    }
    
    // 从 UserDefaults 加载链接历史记录
    private func loadHistoryURLs() {
        
        if let urls = UserDefaults.standard.array(forKey: "HistoryURLs") as? [String] {
            historyURLs = urls
            print("启动时加载历史记录: \(historyURLs)")
        }
        // 加载最后一次访问的链接
        if let lastURL = UserDefaults.standard.string(forKey: "LastVisitedURL") {
            urlString = lastURL
            showWebView = true
            showOverlay = false // 确保覆盖层被隐藏
            print("启动时加载最后访问的URL: \(lastURL)")
        }else {
            print("启动时没有找到最后访问的URL")
        }
        
    }
    
    private func loadEnteredURL() {
        var finalURLString = inputURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 检查用户输入的 URL 是否包含 http:// 或 https:// 前缀
        if !finalURLString.lowercased().hasPrefix("http://") && !finalURLString.lowercased().hasPrefix("https://") {
            // 如果没有，添加 https:// 前缀
            finalURLString = "https://" + finalURLString
        }
        
        // 尝试构造 URL
        if let url = URL(string: finalURLString), let scheme = url.scheme, let host = url.host {
            // 确保 scheme 是 http 或 https，且 host 不为空
            if (scheme == "http" || scheme == "https") && !host.isEmpty {
                urlString = finalURLString // 更新当前链接
                showWebView = true
                showOverlay = false // 关闭覆盖层
                isFirstLoad = false // 更新首次加载状态
                
                // 检查历史记录中是否已经存在该链接，如果不存在则添加
                if let index = historyURLs.firstIndex(of: finalURLString) {
                    // 如果链接已经存在于历史记录中，则将其移到数组末尾
                    historyURLs.remove(at: index)
                    historyURLs.append(finalURLString)
                    // 更新最后访问的链接
                    UserDefaults.standard.set(finalURLString, forKey: "LastVisitedURL")
                } else {
                    // 如果链接不存在于历史记录中，则添加到数组末尾
                    historyURLs.append(finalURLString)
                    // 保持数组大小不超过10
                    // 更新最后访问的链接
                    UserDefaults.standard.set(finalURLString, forKey: "LastVisitedURL")
                    if historyURLs.count > 10 {
                        historyURLs.removeFirst(historyURLs.count - 10)
                    }
                    // 保存链接历史记录
                    saveHistoryURLs()
                    saveIsFirstLoadState() // 保存 isFirstLoad 状态
                }
            }
        }
    }

    
//    
//    private func loadEnteredURL() {
//        var finalURLString = inputURLString.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        // 检查用户输入的 URL 是否包含 http:// 或 https:// 前缀
//        if !finalURLString.lowercased().hasPrefix("http://") && !finalURLString.lowercased().hasPrefix("https://") {
//            // 如果没有，添加 https:// 前缀
//            finalURLString = "https://" + finalURLString
//        }
//        
//        // 尝试构造 URL
//        if let url = URL(string: finalURLString), let scheme = url.scheme, let host = url.host {
//            // 确保 scheme 是 http 或 https，且 host 不为空
//            if (scheme == "http" || scheme == "https") && !host.isEmpty {
//                urlString = finalURLString // 更新当前链接
//                showWebView = true
//                showOverlay = false // 关闭覆盖层
//                isFirstLoad = false // 更新首次加载状态
//                // 检查历史记录中是否已经存在该链接，如果不存在则添加
//                if !historyURLs.contains(finalURLString) {
//                    historyURLs.append(finalURLString)
//                    // 保持数组大小不超过10
//                    if historyURLs.count > 10 {
//                        historyURLs.removeFirst(historyURLs.count - 10)
//                    }
//                    // 保存链接历史记录
//                    saveHistoryURLs()
//                    saveIsFirstLoadState() // 保存 isFirstLoad 状态
//                }
//            }
//        }
//    }
    
    private func refreshWebView() {
        // 发送一个通知，让 WebView 结构体中的 WKWebView 实例刷新页面
        NotificationCenter.default.post(name: .reloadWebView, object: nil)
    }
    
    //    private func refreshWebView() {
    //        // 直接调用 WKWebView 的 reload 方法来刷新页面
    //        webView.reload()
    //    }
    
    
    var body: some View {
//        ZStack{
            VStack {
                HStack{
                    // Close button
                    Button(action: {
                        NSApp.terminate(nil)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12))
                            .foregroundColor(.clear)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(width: 12, height: 12)
                    .background(VisualEffectView(material: .popover , blendingMode: .withinWindow)) // 使用VisualEffectView
                    .cornerRadius(6)
                    
                    GeometryReader { geometry in
                        HStack {  }
                    }
                    .frame(width: 100, height: 12)
                    .background(VisualEffectView(material: .popover, blendingMode: .withinWindow)) // 使用VisualEffectView
                    .cornerRadius(6)
                    .onMouseDragged()
                    
                }
                ZStack{
                    // WebView to load a website
                    if showWebView {
                        // WebView to load a website
                        //                    WebView(url: $urlString)
                        WebView(url: $urlString, key: $webViewKey) // 这里传递了 webViewKey
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .onChange(of: historyURLs) { // 注意这里没有使用 perform 关键字
                                saveHistoryURLs()
                            }
                        
                    }
                    // 覆盖层
                    //                if showOverlay {
                    if isFirstLoad || showOverlay {
                        // 输入框和提示
                        VStack {
                            TextField("input URL", text: $inputURLString)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .frame(width: 300)
                                .onAppear {
                                    self.inputURLString = self.urlString // 默认填充当前链接
                                }
                                .onSubmit { // 监听回车事件
                                    loadEnteredURL() // 调用加载 URL 的方法
                                }
                            Button("Go") {
                                self.loadEnteredURL() // 调用加载 URL 的方法
                            }
                            //                        .padding()
                            .buttonStyle(LargeTextButtonStyle())
                            
                            // 历史链接列表
                            VStack {
                                ForEach(historyURLs, id: \.self) { urlString in
                                    Button(action: {
                                        self.inputURLString = urlString
                                        self.loadEnteredURL()
                                    }) {
                                        Text(urlString)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.clear) // 设置背景为透明
                            Text("⌘+⇧+H：Change URL")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("⌘+⇧+F：Switch the app's floating mode")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("⌘+⇧+R：Reload the pag")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 10)
                            Text("For suggestions on improvements, contact WeChat: whim_liu")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .opacity(0.3) // 这里设置了50%的透明度
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(VisualEffectView(material: .popover , blendingMode: .withinWindow)) // 使用VisualEffectView
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                    }
                    // 当应用程序活跃时显示彩色渐变边框
                    if isActive {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(activeGradient, lineWidth: 2)
                            .padding(0) // 负 padding 以使边框紧贴 ZStack
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                    isActive = true
                }
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
                    isActive = false
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
            .ignoresSafeArea()
            .onAppear {
                NotificationCenter.default.addObserver(forName: .refreshWebView, object: nil, queue: .main) { _ in
                    self.refreshWebView() // 调用刷新 WebView 的方法
                    print("触发refreshWebView")
                }
                NotificationCenter.default.addObserver(forName: .toggleOverlay, object: nil, queue: .main) { _ in
                    self.showOverlay.toggle() // 切换覆盖层的显示状态
                    self.showWebView.toggle() // 切换覆盖层的显示状态
                }
                // Set the window to be transparent and have no title bar
                if let window = NSApp.windows.first {
                    window.titlebarAppearsTransparent = true
                    window.titleVisibility = .hidden
                    window.isOpaque = false
                    window.backgroundColor = NSColor.clear
                    window.styleMask.insert(.fullSizeContentView) // 允许内容视图占满整个窗口
                    window.standardWindowButton(.closeButton)?.isHidden = true
                    window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    window.standardWindowButton(.zoomButton)?.isHidden = true
                    window.isMovableByWindowBackground = true // 允许通过窗口背景移动窗口
                }
                loadIsFirstLoadState() // 加载 isFirstLoad 状态
                if !isFirstLoad {
                    loadHistoryURLs() // 加载链接历史记录和最后一次访问的链接
                }
                //            loadHistoryURLs() // 加载链接历史记录和最后一次访问的链接
                // 如果不是第一次加载，直接加载之前的地址
                //            if !isFirstLoad || !urlString.isEmpty {
                //                loadHistoryURLs() // 加载链接历史记录和最后一次访问的链接
                ////                    showWebView = true
                //
                ////                    showOverlay = false
                //                }
                //            if !isFirstLoad {
                ////                loadEnteredURL()
                //                loadHistoryURLs() // 加载链接历史记录和最后一次访问的链接
                //            }
                // 添加键盘快捷键的监听
//                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
//                    if event.modifierFlags.contains(.command) {
//                        switch event.keyCode {
//                        case 0x7C: // 右方向键
//                            autoHideEnabled = true
//                            AppDelegate.shared.hideWindowToRight()
//                            return nil
//                        case 0x7B: // 左方向键
//                            autoHideEnabled = false
//                            AppDelegate.shared.showWindowFromRight()
//                            return nil
//                        default:
//                            break
//                        }
//                    }
//                    return event
//                }
            }
            // 活跃状态的渐变边框
            var activeGradient: LinearGradient {
                LinearGradient(
//                                    gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing
                    gradient: Gradient(colors: [Color.white.opacity(0.5), Color.gray.opacity(0.4)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            // 添加一个透明的视图来监听鼠标事件
//                      Color.clear
//                          .contentShape(Rectangle())
//                          .onHover(perform: { hovering in
//                              if autoHideEnabled {
//                                  if hovering {
//                                      AppDelegate.shared.showWindowFromRight()
//                                  } else {
//                                      AppDelegate.shared.hideWindowToRight()
//                                  }
//                              }
//                          })
//        }
    }
    
}


struct WebView: NSViewRepresentable {
    @Binding var url: String // 使用 @Binding 来响应外部状态的变化
    @Binding var key: UUID // 添加这一行
    
    // 创建视图
    func makeNSView(context: Context) -> NSView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = .popover
        visualEffectView.blendingMode = .withinWindow
        visualEffectView.state = .active
        
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: URL(string: url)!))
        
        // 添加监听器
        NotificationCenter.default.addObserver(forName: .reloadWebView, object: nil, queue: .main) { _ in
            webView.reload()
        }
        
        // 禁用 WKWebView 的背景绘制
        webView.setValue(false, forKey: "drawsBackground")
        
        // 将 WKWebView 添加到 NSVisualEffectView 中
        visualEffectView.addSubview(webView)
        
        // 设置 WKWebView 的 Auto Layout 约束
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor)
        ])
        
        return visualEffectView // 返回包含 WKWebView 的 NSVisualEffectView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        guard let visualEffectView = nsView as? NSVisualEffectView,
              let webView = visualEffectView.subviews.first as? WKWebView,
              let url = URL(string: self.url) else {
            print("无法获取到 WKWebView 或 URL")
            return
        }
        
        // 重新加载 URL
        webView.load(URLRequest(url: url))
        print("WebView 正在重新加载 URL")
    }
    
    
    //    func updateNSView(_ nsView: NSView, context: Context) {
    //        // 获取到 NSView 中的 WKWebView 实例
    //        guard let visualEffectView = nsView as? NSVisualEffectView,
    //              let webView = visualEffectView.subviews.first as? WKWebView,
    //              let url = URL(string: self.url) else {
    //            print("无法获取到 WKWebView 或 URL")
    //            return
    //        }
    //
    //        // 重新加载 URL
    //        webView.load(URLRequest(url: url))
    //        print("WebView 正在重新加载 URL")
    //    }
    
    
    //    func updateNSView(_ nsView: NSView, context: Context) {
    //        // 这里不需要检查 key 是否变化，因为 key 的任何变化都会触发这个方法
    //        if let webView = nsView.subviews.first as? WKWebView, let url = URL(string: self.url) {
    //            webView.load(URLRequest(url: url))
    //            print("updateNSView了")
    //        }
    //    }
    
    
    //    func updateNSView(_ nsView: NSView, context: Context) {
    //        // 由于我们只是需要重新加载相同的 URL，所以这里不需要检查 key 的变化
    //        // 只要这个方法被调用，我们就重新加载 URL
    //        if let webView = nsView.subviews.first as? WKWebView, let url = URL(string: self.url) {
    //            webView.load(URLRequest(url: url))
    //        }
    //    }
    
    //    func updateNSView(_ nsView: NSView, context: Context) {
    //        if let webView = nsView.subviews.first as? WKWebView, let url = URL(string: self.url) {
    //            webView.load(URLRequest(url: url))
    //        }
    //    }
    
    
    //    func updateNSView(_ nsView: NSView, context: Context) {
    //        if let webView = nsView.subviews.first as? WKWebView {
    //            webView.load(URLRequest(url: URL(string: url)!))
    //        }
    //    }
    
    //    func updateNSView(_ nsView: NSView, context: Context) {
    //        if let webView = nsView as? WKWebView, let url = URL(string: self.url) {
    //            webView.load(URLRequest(url: url))
    //        }
    //    }
    
    // 创建协调器
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    
    // 协调器类
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let jsString = """
                       document.documentElement.style.setProperty('--gray', 'transparent');
                       document.documentElement.style.setProperty('--primary', 'rgba(34, 34, 34, 1)');
                       document.documentElement.style.setProperty('--white', 'rgba(255, 255, 255, 0.05)');
                       document.documentElement.style.setProperty('--second', 'rgba(255, 255, 255, 0.3)');
                    var style = document.createElement('style');
                               style.innerHTML = '.chat_chat-message-item__dKqMl { background-color: white !important; }';
                               document.head.appendChild(style);
                   
                   """
            webView.evaluateJavaScript(jsString, completionHandler: nil)
        }
    }
    
}


struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

extension View {
    func onMouseDragged() -> some View {
        return self.overlay(
            MouseDragDetectorView()
        )
    }
}

struct MouseDragDetectorView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.addTrackingArea(NSTrackingArea(rect: view.bounds, options: [.activeAlways, .mouseMoved], owner: view, userInfo: nil))
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
    }
}

extension NSView {
    open override func mouseDragged(with event: NSEvent) {
        if let window = self.window {
            let currentLocation = window.frame.origin
            let newOrigin = NSPoint(x: currentLocation.x + event.deltaX, y: currentLocation.y - event.deltaY)
            window.setFrameOrigin(newOrigin)
        }
    }
}



struct LargeTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.body) // 设置文本字体大小为标题大小
            .padding([.leading,.trailing], 12) // 顶部和左侧内边距为 10
            .padding([.top,.bottom], 8) // 底部和右侧内边距为 20
            .background(Color.white.opacity(0.5)) // 设置背景为70%透明度的白色
            .foregroundColor(.black) // 设置文本颜色为黑色
            .clipShape(RoundedRectangle(cornerRadius: 8)) // 设置圆角矩形边框
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // 点击时缩小效果
            .animation(.easeOut, value: configuration.isPressed) // 添加动画效果
    }
}

extension Notification.Name {
    // ... 省略其他代码 ...
    static let reloadWebView = Notification.Name("reloadWebView")
}
struct MouseTrackingView: NSViewRepresentable {
    var onEntered: () -> Void
    var onExited: () -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        // 设置 trackingArea 的 owner 为 Coordinator
        let trackingArea = NSTrackingArea(rect: view.bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: context.coordinator, userInfo: nil)
        view.addTrackingArea(trackingArea)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onEntered: onEntered, onExited: onExited)
    }

    class Coordinator: NSObject {
        var onEntered: () -> Void
        var onExited: () -> Void

        init(onEntered: @escaping () -> Void, onExited: @escaping () -> Void) {
            self.onEntered = onEntered
            self.onExited = onExited
        }

        // 不使用 override 关键字
        @objc func mouseEntered(with event: NSEvent) {
            onEntered()
        }

        @objc func mouseExited(with event: NSEvent) {
            onExited()
        }
    }
}



//struct MouseTrackingView: NSViewRepresentable {
//    var onEntered: () -> Void
//    var onExited: () -> Void
//
//    func makeNSView(context: Context) -> NSView {
//        let view = NSView()
//        let trackingArea = NSTrackingArea(rect: view.bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: context.coordinator, userInfo: nil)
//        view.addTrackingArea(trackingArea)
//        return view
//    }
//
//    func updateNSView(_ nsView: NSView, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(onEntered: onEntered, onExited: onExited)
//    }
//
//    class Coordinator: NSObject {
//        var onEntered: () -> Void
//        var onExited: () -> Void
//
//        init(onEntered: @escaping () -> Void, onExited: @escaping () -> Void) {
//            self.onEntered = onEntered
//            self.onExited = onExited
//        }
//
//        override func mouseEntered(with event: NSEvent) {
//            onEntered()
//        }
//
//        override func mouseExited(with event: NSEvent) {
//            onExited()
//        }
//    }
//}
