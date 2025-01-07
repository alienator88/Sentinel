# Sentinel
<p align="center">
  <img src="https://github.com/alienator88/Sentinel/assets/6263626/2c3d699d-eea6-49db-8a7d-cc66e0ce9b97" width="100" height="100" />
   <br />
   <strong>Status: </strong>Maintained 
   <br />
   <strong>Version: </strong>2.1
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
- Can drop an app in the drop target to unquarantine
- Can drop an app in the drop target to ad-hoc self sign and replace the certificate
- Custom auto-updater that pulls latest release notes and binaries from GitHub Releases (Sentinel should be ran from /Applications folder to avoid permission issues)
- Supports macOS Sequoia



## Screenshots

<img src="https://github.com/alienator88/Sentinel/assets/6263626/43a8bab1-9bb1-40b2-82ce-62c91b57e066" align="left" width="400" />

<img src="https://github.com/alienator88/Sentinel/assets/6263626/7cbf2e86-e73c-49d6-9fca-cfeb0273bab2" align="center" width="400" />


## Requirements
- MacOS 12.0+ (App uses a lot of newer SwiftUI functions/modifiers which don't work on any OS lower than 12.0)

## Getting Sentinel

<details>
  <summary>Releases</summary>

> Pre-compiled, always up-to-date versions are available from my releases page.
</details>

<details>
  <summary>Homebrew</summary>
   
> Execute the following command to install via Homebrew:
```
brew install alienator88/homebrew-cask/sentinel-app
```
</details>


## License
> [!IMPORTANT]
> Sentinel is licensed under Apache 2.0 with [Commons Clause](https://commonsclause.com/). This means that you can do anything you'd like with the source, modify it, contribute to it, etc., but the license explicitly prohibits any form of monetization for Sentinel or any modified versions of it. See full license [HERE](https://github.com/alienator88/Sentinel/blob/main/LICENSE.md)
> 

## Thanks

Much appreciation to [Wynioux]([https://freemacsoft.net/appcleaner/](https://github.com/wynioux/macOS-GateKeeper-Helper)) for their Gatekeeper script used as inspiration.

## Some of my apps

[Pearcleaner](https://github.com/alienator88/Pearcleaner) - An opensource app cleaner with privacy in mind

[Sentinel](https://github.com/alienator88/Sentinel) - A GUI for controlling gatekeeper status on your mac

[Viz](https://github.com/alienator88/Viz) - Utility for extracting text from images, videos, qr/barcodes
