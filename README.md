# Sentinel
<p align="center">
  <img src="https://github.com/alienator88/Sentinel/assets/6263626/2c3d699d-eea6-49db-8a7d-cc66e0ce9b97" width="100" height="100" />
   <br />
   <strong>Status: </strong>Maintained 
   <br />
   <strong>Version: </strong>1.4
   <br />
   <a href="https://github.com/alienator88/Sentinel/releases"><strong>Download</strong></a>
    · 
   <a href="https://github.com/alienator88/Sentinel/commits">Commits</a>
   <br />
   <br />
</p>
</br>

A GUI for controlling Gatekeeper and more, written in SwiftUI. Using this as a learning opportunity for Swift as I'm new to it.


## Features
- 100% Swift
- Small app size (<1MB)
- Can drop an app in the drop target to unquarantine
- Can drop an app in the drop target to ad-hoc self sign and replace the certificate
- Custom auto-updater that pulls latest release notes and binaries from GitHub Releases (Pearcleaner has to run from /Applications folder for this to work because of permissions)



## Screenshots

<img src="https://github.com/alienator88/Sentinel/assets/6263626/43a8bab1-9bb1-40b2-82ce-62c91b57e066" align="left" width="400" />

<img src="https://github.com/alienator88/Sentinel/assets/6263626/7cbf2e86-e73c-49d6-9fca-cfeb0273bab2" align="center" width="400" />


## Requirements
- MacOS 12.0+ (App uses a lot of newer SwiftUI functions/modifiers which don't work on any OS lower than 12.0)
- Open Sentinel first time by right clicking and selecting Open. This adds an exception to Gatekeeper so it doesn't complain about the app not being signed with an Apple Developer certificate


## Getting Sentinel

<details>
  <summary>Releases</summary>

> Pre-compiled, always up-to-date versions are available from my releases page.
</details>

<details>
  <summary>Homebrew</summary>
   
> Since I don't have a paid developer account, I can't submit to the main Homebrew cask repo.
You can still add the app via Homebrew by tapping my homebrew repo:
```
brew install alienator88/homebrew-cask/sentinel
```
</details>

## Thanks

Much appreciation to [Wynioux]([https://freemacsoft.net/appcleaner/](https://github.com/wynioux/macOS-GateKeeper-Helper)) for their Gatekeeper script used as inspiration.
