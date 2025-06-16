# Sentinel
<p align="center">
  <img src="https://github.com/user-attachments/assets/8730f94d-b4d0-432e-a893-68bb735684bd" width="100" height="100" />
   <br />
   <strong>Status: </strong>Maintained 
   <br />
   <strong>Version: </strong>3.0.0
   <br />
   <a href="https://github.com/alienator88/Sentinel/releases"><strong>Download</strong></a>
    · 
   <a href="https://github.com/alienator88/Sentinel/commits">Commits</a>
   <br />
   <br />
</p>
</br>

A GUI for controlling Gatekeeper, unquarantining apps and signing apps.


## Features
- 100% Swift
- Can drop an app in the drop target to unquarantine and optionally auto-open the app after it is unquarantined
- Can drop an app in the drop target to ad-hoc self sign and replace the certificate
- Custom auto-updater that pulls latest release notes and binaries from GitHub Releases (Sentinel should be ran from /Applications folder to avoid permission issues)
- Supports macOS Sequoia



## Screenshots

<img src="https://github.com/user-attachments/assets/2b6d1418-b8e5-4da9-afe6-a036ea9d04e1" align="left" width="400" />

<img src="https://github.com/user-attachments/assets/1fd11c44-159b-4d90-80e3-9c0b2c825dc6" align="center" width="400" />

## Requirements
- MacOS 13.0+ (App uses a lot of newer SwiftUI functions/modifiers which don't work on any OS lower than Ventura)

## Getting Sentinel

<details>
  <summary>Releases</summary>

> Pre-compiled, always up-to-date versions are available from my releases page.
</details>

<details>
  <summary>Homebrew</summary>
   
> Execute the following command to install via Homebrew:
```
brew install alienator88-sentinel
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

[PearHID](https://github.com/alienator88/PearHID) - Remap your macOS keyboard with a simple SwiftUI frontend
