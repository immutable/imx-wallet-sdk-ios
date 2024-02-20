<div align="center">
  <p align="center">
    <a  href="https://docs.x.immutable.com/docs">
      <img src="https://cdn.dribbble.com/users/1299339/screenshots/7133657/media/837237d447d36581ebd59ec36d30daea.gif" width="280"/>
    </a>
  </p>
</div>

---
# 🚨 This library is no longer maintained 🚨

If you're building apps with Immutable, please use [Immutable's Unified SDK](https://github.com/immutable/ts-immutable-sdk)

# ImmutableX Wallet SDK iOS

The ImmutableX Wallet SDK iOS provides an easy way to connect your users Layer 1 Ethereum wallets and the derivation of an Immutable Layer 2 wallet.

Once both wallets are connected you will have access to the `Signer` (L1 wallet) and `StarkSigner` (L2 wallet) which can be used to perform transactions on ImmutableX.

Session management is handled for you and any changes to the wallets connection will be notified through the callback.

## Supported Wallet Providers

* Any wallet that supports [WalletConnect v1.0](https://walletconnect.com/)

## Installation

This SDK is closed source and only available as a XCTFramework through Cocoapods.

### Prerequisites

* iOS 13.0
* Swift 5.7

### Cocoapods

In your `Podfile`:

```ruby
# Important: ensure this source is specified in the Podfile
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '13.0'
use_frameworks!

target 'MyApp' do
  pod 'ImmutableXWallet'
end
```

## Handle callbacks

All the `ImmutableXWallet` methods (connect, disconnect, etc.) are asynchronous, and will only return when they've completed the operation. If a user is taken to a wallet app for a connection or signature and does not perform the required operation, the request will not complete, leading to a [pending state](#pending-states) that is communicated via the callback.

Status callbacks are also useful for listening to status updates triggered from different screens.

### Set callback

```swift
ImmutableXWallet.shared
    .setStatusCallbackForId("unique identifier") { status in
        switch status {
        case .connecting:
            // Waiting for a provider to connect or restarting a previous session.
            break

        case .pendingConnection:
            // Emitted when the app has returned to the foreground after triggering a connection request but doesn't have a
            // result yet.
            break

        case .pendingSignature:
            // Emitted when the app has returned to the foreground after triggering a signature request but doesn't have a
            // result yet.
            break

        case .connected:
            // An L1 wallet is connected and an L2 wallet is successfully derived.
            break

        case .disconnecting:
            // Waiting for a provider to disconnect.
            break

        case .disconnected:
            // A wallet moves from Connected to Disconnected. Failure to connect will throw an error.
            break
        }
}
```

### Pending states

If a wallet app has been launched to connect or sign and your app has resumed but no result has arrived, `.pendingConnection` or `.pendingSignature` will be sent to the callback.

This allows you to handle this scenario flexibly; you could re-launch their wallet and complete the flow, show a popup or continue showing a waiting state, for example.

### Remove callback

You may unregister from all callbacks

```swift
ImmutableXWallet.shared.removeAllStatusCallbacks()
```

or remove a specific one

```swift
ImmutableXWallet.shared.removeStatusCallbackForId("unique identifier")
```

## Connect wallet

### Connect via WalletConnect

```swift
try await ImmutableXWallet.shared.connect(
    to: .walletConnect(
        config: .init(
            appURL: URL(string: "https://immutable.com")!,
            appName: "ImmutableX Sample",
            // The Universal Link or URL Scheme of the chosen wallet to be connected.
            walletDeeplink: "https://metamask.app.link"
        )
    )
)
```

> **NOTE**: the async methods that require user actions with the chosen wallet app will only complete when the requested action has been performed (i.e. accepted or denied).

If you want to use your own bridge server instead of the default provide it via `bridgeServer` when connecting. For more info on how WalletConnect and the bridge works [see here](https://docs.walletconnect.com/tech-spec).

## Restart existing session

The user's previous wallet sessions will be automatically restored when the app is launched, however it can also be manually triggered.

```swift
try await ImmutableXWallet.shared.restartSession()
```

## Disconnect wallet

```swift
try await ImmutableXWallet.shared.disconnect()
```

## Usage with the Core SDK

This Wallet SDK is designed to be used in tandem with the [ImmutableX Core SDK for Swift](https://github.com/immutable/imx-core-sdk-swift).

Once you connect a user's wallet with the Wallet SDK you can provide the `Signer` and `StarkSigner` instances to Core SDK workflows.

```swift
guard let signer = ImmutableXWallet.shared.signer, 
    let starkSigner = ImmutableXWallet.shared.starkSigner else {
    // handle not connected
    return
}

let result = try await ImmutableX.shared.createTrade(
    orderId: orderId, 
    signer: signer, 
    starkSigner: starkSigner
)
```

## Changelog Management

The following headings should be used as appropriate

* Added
* Changed
* Deprecated
* Removed
* Fixed

What follows is an example with all the change headings, for real world use only use headings when appropriate.

This goes at the top of the `CHANGELOG.md` above the most recent release:

```markdown
...

## [Unreleased]

### Added

for new features.

### Changed

for changes in existing functionality.

### Deprecated

for soon-to-be removed features.

### Removed

for now removed features.

### Fixed

for any bug fixes.

...
```

## Contributing

If you would like to contribute by reporting bugs or suggest enchacements, please read our [contributing guide](https://github.com/immutable/imx-wallet-sdk-ios/blob/main/CONTRIBUTING.md).

## Getting Help

ImmutableX is open to all to build on, with no approvals required. If you want to talk to us to learn more, or apply for developer grants, click below:

[Contact us](https://www.immutable.com/contact)

### Project Support

To get help from other developers, discuss ideas, and stay up-to-date on what's happening, become a part of our community on Discord.

[Join us on Discord](https://discord.gg/TkVumkJ9D6)

You can also join the conversation, connect with other projects, and ask questions in our ImmutableX Discourse forum.

[Visit the forum](https://forum.immutable.com/)

#### Still need help?

You can also apply for marketing support for your project. Or, if you need help with an issue related to what you're building with ImmutableX, click below to submit an issue. Select _I have a question_ or _issue related to building on ImmutableX_ as your issue type.

[Contact support](https://support.immutable.com/hc/en-us/requests/new)

## License

ImmutableX Wallet SDK iOS repository is distributed under the terms of the [Apache License (Version 2.0)](https://github.com/immutable/imx-wallet-sdk-ios/blob/main/LICENSE).
