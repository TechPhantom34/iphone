//
//  AdViewController.swift
//  Flappy Bird
//
//  Created by Alen on 3/29/26.
//  Copyright © 2026 Brandon Plank & Thatcher Clough. All rights reserved.
//

import UIKit
import WebKit

class AdViewController: UIViewController, WKScriptMessageHandler {
var webView: WKWebView!
var adCompleted = false

```
override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .black
    
    // WKWebView configuration
    let config = WKWebViewConfiguration()
    config.userContentController.add(self, name: "adCallback")
    
    webView = WKWebView(frame: view.bounds, configuration: config)
    webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(webView)
    
    // Load HTML with GPT rewarded ads
    loadAdHTML()
}

private func loadAdHTML() {
    let html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Flappy Bird - Rewarded Ad</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            body {
                background: #000;
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                color: #fff;
            }
            .container {
                text-align: center;
                padding: 20px;
                width: 100%;
            }
            .status {
                font-size: 18px;
                margin: 20px 0;
                color: #ffc107;
                font-weight: bold;
            }
            .error {
                color: #f44336;
            }
            .success {
                color: #4caf50;
            }
            h1 {
                margin-bottom: 30px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🐦 Flappy Bird</h1>
            <div class="status" id="status">Loading rewarded ad...</div>
        </div>
    
        <script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js"></script>
        <script>
            window.googletag = window.googletag || {cmd: []};
            
            let rewardedSlot = null;
            let adStarted = false;
            let adGranted = false;
            
            function initRewardedAd() {
                googletag.cmd.push(function() {
                    console.log("Initializing rewarded ad...");
                    
                    // Out-of-page slot tanımla (rewarded ads için)
                    rewardedSlot = googletag.defineOutOfPageSlot(
                        '/23102680889,22946338043/MB_BDL_DELTAEXECUTOR_REWARDED_0',
                        googletag.enums.OutOfPageFormat.REWARDED
                    );
                    
                    if (!rewardedSlot) {
                        console.log("Ad fail");
                        updateStatus('Rewarded ad not available', 'error');
                        window.webkit.messageHandlers.adCallback.postMessage({status: 'failed'});
                        setTimeout(() => {
                            window.webkit.messageHandlers.adCallback.postMessage({status: 'close'});
                        }, 1500);
                        return;
                    }
                    
                    rewardedSlot.addService(googletag.pubads());
                    
                    // RewardedSlotReadyEvent - Ad hazır ve gösterilmeye uygun
                    googletag.pubads().addEventListener('rewardedSlotReady', function(event) {
                        console.log("Ad started");
                        adStarted = true;
                        updateStatus('Ad is playing...', 'status');
                        window.webkit.messageHandlers.adCallback.postMessage({status: 'started'});
                        
                        // Ödüllü reklamı göster
                        event.makeRewardedUserDecision();
                    });
                    
                    // RewardedSlotGrantedEvent - Ödül verildi
                    googletag.pubads().addEventListener('rewardedSlotGranted', function(event) {
                        console.log("Ad finish");
                        adGranted = true;
                        updateStatus('Ad completed! Reward granted!', 'success');
                        window.webkit.messageHandlers.adCallback.postMessage({status: 'finished'});
                        
                        setTimeout(() => {
                            window.webkit.messageHandlers.adCallback.postMessage({status: 'close'});
                        }, 1500);
                    });
                    
                    // RewardedSlotClosedEvent - Ad kapatıldı
                    googletag.pubads().addEventListener('rewardedSlotClosed', function(event) {
                        if (!adGranted) {
                            console.log("Ad fail");
                            updateStatus('Ad was closed without reward', 'error');
                            window.webkit.messageHandlers.adCallback.postMessage({status: 'failed'});
                            
                            setTimeout(() => {
                                window.webkit.messageHandlers.adCallback.postMessage({status: 'close'});
                            }, 1500);
                        }
                    });
                    
                    // Services'i aktifleştir ve ad'ı göster
                    googletag.enableServices();
                    googletag.display(rewardedSlot);
                });
            }
            
            function updateStatus(message, className) {
                const statusDiv = document.getElementById('status');
                statusDiv.textContent = message;
                statusDiv.className = 'status ' + className;
            }
            
            // Ad'ı initialize et
            initRewardedAd();
            googletag.pubads().set('page_url', 'https://delta-executor.com');
        </script>
    </body>
    </html>
    """
    
    webView.loadHTMLString(html, baseURL: nil)
}

// MARK: - WKScriptMessageHandler
func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    guard let body = message.body as? [String: String],
          let status = body["status"] else { return }
    
    switch status {
    case "started":
        print("📱 Ad started")
        
    case "finished":
        print("✅ Ad finished successfully")
        adCompleted = true
        
    case "failed":
        print("❌ Ad failed")
        // Close app on ad failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
        
    case "close":
        print("🔚 Closing ad controller")
        dismissAdViewController()
        
    default:
        break
    }
}

private func dismissAdViewController() {
    DispatchQueue.main.async {
        self.dismiss(animated: true, completion: nil)
    }
}

deinit {
    webView.configuration.userContentController.removeScriptMessageHandler(forName: "adCallback")
}
```

}