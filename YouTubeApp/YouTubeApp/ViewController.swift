import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var webView: WKWebView!
    var progressView: UIProgressView!
    var observation: NSKeyValueObservation?

    // MARK: - Status bar hidden + edge-to-edge

    override var prefersStatusBarHidden: Bool { return true }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .none }

    override func loadView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 Safari/604.1"
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Extend layout under status bar and home indicator
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true

        setupProgressBar()
        setupRefreshControl()
        loadYouTube()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Keep webView pinned to screen edges, ignoring safe area
        webView.frame = view.bounds
    }

    private func loadYouTube() {
        guard let url = URL(string: "https://www.youtube.com") else { return }
        var request = URLRequest(url: url)
        request.cachePolicy = .useProtocolCachePolicy
        webView.load(request)
    }

    // MARK: - Progress bar (pinned to very top of screen)

    private func setupProgressBar() {
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = .clear
        progressView.progressTintColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        view.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])

        observation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
            guard let self = self, let progress = change.newValue else { return }
            self.progressView.setProgress(Float(progress), animated: true)
            self.progressView.isHidden = progress >= 1.0
        }
    }

    // MARK: - Pull to refresh

    private func setupRefreshControl() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(reloadPage(_:)), for: .valueChanged)
        webView.scrollView.addSubview(refresh)
    }

    @objc func reloadPage(_ sender: UIRefreshControl) {
        webView.reload()
        sender.endRefreshing()
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
        // Inject CSS to remove YouTube's own top padding added for safe area
        let js = """
            var style = document.createElement('style');
            style.innerHTML = 'ytd-app { --ytd-toolbar-offset: 0px !important; }';
            document.head.appendChild(style);
        """
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        showOfflinePage()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        showOfflinePage()
    }

    // MARK: - WKUIDelegate (handle YouTube target="_blank" links)

    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }

    // MARK: - Offline fallback

    private func showOfflinePage() {
        let html = """
        <html><body style="background:#0f0f0f;color:#fff;font-family:-apple-system;
        display:flex;flex-direction:column;align-items:center;justify-content:center;
        height:100vh;margin:0;text-align:center;">
        <svg width="80" height="56" viewBox="0 0 80 56">
          <rect width="80" height="56" rx="12" fill="#FF0000"/>
          <polygon points="32,14 32,42 58,28" fill="white"/>
        </svg>
        <h2 style="margin-top:24px">No Internet Connection</h2>
        <p style="color:#aaa;font-size:14px">Check your connection and try again.</p>
        <button onclick="window.location.reload()"
          style="margin-top:20px;padding:12px 28px;background:#FF0000;color:#fff;
          border:none;border-radius:20px;font-size:16px;cursor:pointer;">
          Retry
        </button></body></html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }

    deinit {
        observation?.invalidate()
    }
}
