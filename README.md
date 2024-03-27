# Sentinel

<img src="https://user-images.githubusercontent.com/6263626/227031704-96a1b004-b0bc-4286-a66a-5807b0c6807a.png" width="100" height="100" />

A GUI for controlling Gatekeeper and more, written in SwiftUI. Using this as a learning opportunity for Swift as I'm new to it.

## Screenshots

![Screenshot 2024-03-26 at 6 17 57 PM](https://github.com/alienator88/Sentinel/assets/6263626/43a8bab1-9bb1-40b2-82ce-62c91b57e066)
![Screenshot 2024-03-26 at 6 18 05 PM](https://github.com/alienator88/Sentinel/assets/6263626/7cbf2e86-e73c-49d6-9fca-cfeb0273bab2)

## Getting Sentinel

Pre-compiled, always up-to-date versions are available from my releases page. (See compilation instructions below)

You might need to run this before opening the app as I don't have a paid developer account: 

`sudo xattr -rd com.apple.quarantine "PATH_TO_APP"`

## Homebrew:
`brew install alienator88/homebrew-cask/sentinel`


## Compiling Sentinel

Compiling Sentinel is simple, as it does not have many dependencies.

Prerequisites:

* macOS Ventura or newer
* Xcode 14.2 or newer
* Git
* An Apple Developer accout. **You don't need a paid one! Even a free one works perfectly**

Instructions:

**Before you begin**

0. Enroll your account in the developer program at [https://developer.apple.com/](https://developer.apple.com/)
1. Install Xcode
2. Add your Developer account to Xcode. To do so, in the Menu bar, click `Xcode → Settings`, and in the window that opens, click `Accounts`. You can add your account there
3. After you add your account, it will appear in the list of Apple IDs on the left od the screen. Select your account there
4. At the bottom of the screen, click `Manage Certificates...`
5. On the bottom left, click the **+** icon and select `Apple Development`
6. When a new item appears in the list called `Apple Development Certificates`, you can press `Done` to close the account manager

**Compiling Sentinel**

1. Clone this repo using `git clone https://github.com/alienator88/Sentinel.git && cd Sentinel && open .`
2. Double-click `Sentinel.xcodeproj`. Xcode should open the project
3. In the Menu Bar, click `Product → Archive` and wait for the building to finish
4. A new window will open. From the list of Sentinel rows, select the topmost one, and click `Distribute App`
5. Click `Copy App`
6. Open the resulting folder. You'll see an app called Sentinel. Drag Sentinel to your `/Applications/` folder, and you're done!

## Thanks

Much appreciation to wynioux for their awesome CLI tool to base this idea on: https://github.com/wynioux/macOS-GateKeeper-Helper

## License

Sentinel is licensed under [TheUnlicense](https://unlicense.org/).

Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.
