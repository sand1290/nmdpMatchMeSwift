
import SwiftUI
import WebKit

struct TiktokFeedView: View {
    let urls = [
        "https://www.tiktok.com/@nmdp_/video/7341010411678330154",
        "https://www.tiktok.com/@nmdp_/video/7328848307897765162",
        "https://www.tiktok.com/@nmdp_/video/7314932108382494034"
    ]

    var body: some View {
        TabView {
            ForEach(urls, id: \.self) { url in
                WebView(url: URL(string: url)!)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .ignoresSafeArea()
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}

#Preview {
    TiktokFeedView()
}
