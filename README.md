# MastodonManager

Manage which Mastodon client to open links with.
*Supports iOS/iPadOS 14 and above.*

Try original BrowserManager in [Neptune](https://www.twitter.com/NeptuneApp_ "Neptune")

Try MastodonManager in [Bookmarks](https://apps.apple.com/app/id1590304377 "Bookmarks")

## How to use
### Set up
Add 'Queried URL Schemes' to info.plist, and add mastodon, ivory, icecubesapp, mammoth

### The Default Browser
Open in default browser if not modified.
```swift
MastodonManager.shared.defaultApp
```
**How to change the default Mastodon app**
```swift
let ivory = MastodonManager.shared.supportedApps.ivory
MastodonManager.shared.defaultApp = ivory
```

### Get installed Mastodon apps
```swift
MastodonManager.shared.installedApps
```

### Open URL with default Mastodon app
```swift
MastodonManager.shared.open(url: {YOUR URL}, presentingController: self)
```

## Supported Apps
- Mastodon [App Store][MastodonApp-AppStore]
- Ivory [App Store][Ivory-AppStore]
- Ice Cubes [App Store][IceCubes-AppStore]
- Mammoth [Homepage][Mammoth-Homepage]

[MastodonApp-AppStore]: https://getmammoth.app/
[Ivory-AppStore]: https://apps.apple.com/app/id6444602274
[IceCubes-AppStore]: https://apps.apple.com/app/id6444915884
[Mammoth-Homepage]: https://getmammoth.app/
