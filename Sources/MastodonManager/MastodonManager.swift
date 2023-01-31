//
//  MastodonManager.swift
//  Created by Yuto Iwakami
//
//  BrowserManager.swift
//  Created by Ethan Lipnik.
//

import Foundation

#if !os(macOS)
import UIKit
import SafariServices

open class MastodonManager {
    public static let shared = MastodonManager()
    private let userDefaults = UserDefaults.standard
    
    public struct MastodonApps {
        let mastodon = MastodonApp(scheme: URL(string: "mastodon://"), name: "Mastodon")
        let icecubes = MastodonApp(scheme: URL(string: "IceCubesApp://"), name: "Ice Cubes")
        let ivory = MastodonApp(scheme: URL(string: "ivory://"), name: "Ivory")
        let mammoth = MastodonApp(scheme: URL(string: "mammoth://"), name: "Mammoth")
        let inApp = MastodonApp(name: "In-App Browser")
        let browser = MastodonApp(name: "Browser")
        
        lazy var array: [MastodonApp] = {
            return [ivory, icecubes, mammoth, inApp, browser]
        }()
    }
    
    open var supportedApps = MastodonApps()
    
    open var installedApps: [MastodonApp] {
        get {
            return supportedApps.array.filter({ $0.isInstalled() })
        }
    }
    
    open var defaultApp: MastodonApp {
        get {
            return (installedApps.first(where: { $0.name == userDefaults.string(forKey: "Default.Mastodon") }) ?? MastodonApp(name: "Browser"))
        }
        set(value) {
            
            guard installedApps.contains(where: { $0 == value }) else {
                self.defaultApp = (installedApps.first(where: { $0.name == userDefaults.string(forKey: "Default.Mastodon") }) ?? MastodonApp(name: "Browser"))
                
                return
            }
            
            userDefaults.set(value.name, forKey: "Default.Mastodon")
        }
    }
    
    
    private let appShared = UIApplication.shared
    
    private func encodeByAddingPercentEscapes(_ input: String) -> String {
        return NSString(string: input).addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]"))!
    }
    
    open func open(url: URL, openWith: MastodonApp? = nil, presentingController: UIViewController? = nil, completion: ((() -> Void))? = nil) {
        DispatchQueue.main.async { [weak self] in
            
            func openBrowser() {
                self?.appShared.open(url, options: [:]) { (_) in
                    completion?()
                }
            }
            
            func openInApp(){
                let sfvc = SFSafariViewController(url: url)
                sfvc.modalPresentationStyle = .fullScreen
                if let vc = presentingController {
                    sfvc.modalPresentationStyle = .pageSheet
                    vc.present(sfvc, animated: true) {
                        completion?()
                    }
                } else {
                    let connectedScenes = UIApplication.shared.connectedScenes
                        .filter { $0.activationState == .foregroundActive }
                        .compactMap { $0 as? UIWindowScene }
                    if let currentWindow = connectedScenes.first?.windows.first(where: { $0.isKeyWindow }) {
                        currentWindow.rootViewController?.present(sfvc, animated: true, completion: nil)
                    } else {
                        openBrowser()
                    }
                }
            }
            
            #if targetEnvironment(macCatalyst)
            openBrowser()
            #else
            var app:MastodonApp!
            if openWith == nil{
                app = self?.defaultApp
            } else {
                app = openWith
            }
            
            switch app.name {
            case "Browser":
                openBrowser()
            case "In-App Browser":
                openInApp()
            case "Ivory":
                if let finalURL = URL(string: "ivory://acct/openURL?url=\(url)") {
                    self?.appShared.open(finalURL, options: [:], completionHandler: { (_) in
                        print(finalURL)
                        completion?()
                    })
                } else {
                    openBrowser()
                }
            case "Mammoth":
                if let scheme = app.scheme, let finalURL = URL(string: scheme.absoluteString + url.absoluteString) {
                    self?.appShared.open(finalURL, options: [:], completionHandler: { (_) in
                        print(finalURL)
                        completion?()
                    })
                } else {
                    openBrowser()
                }
            case "Ice Cubes":
                if let scheme = app.scheme, let finalURL = URL(string: scheme.absoluteString + url.absoluteString.replacingOccurrences(of: "https://", with: "")) {
                    self?.appShared.open(finalURL, options: [:], completionHandler: { (_) in
                        print(finalURL)
                        completion?()
                    })
                } else {
                    openBrowser()
                }
            default:
                openBrowser()
            }
            #endif
        }
    }
}

public struct MastodonApp: Equatable {
    public var scheme: URL? = nil
    public let app = UIApplication.shared
    public let name: String
    
    public func isInstalled() -> Bool {
        guard let scheme = scheme else { return true }
        return app.canOpenURL(scheme)
    }
}

#endif
