Pod::Spec.new do |s|
    s.name             = 'ImmutableXWalletSDK'
    s.version          = '0.1.0'
    s.summary          = 'The ImmutableX Wallet SDK iOS for applications written on the ImmutableX platform.'
    s.description      = <<-DESC
    The ImmutableX Wallet SDK iOS provides an easy way to connect your users Layer 1 Ethereum wallets and the derivation of an Immutable Layer 2 wallet.

    Once both wallets are connected you will have access to the Signer (L1 wallet) and StarkSigner (L2 wallet) which can be used to perform transactions on ImmutableX.

    Session management is handled for you and any changes to the wallets connection will be notified through the callback.
                          DESC
    s.homepage         = 'https://github.com/immutable/imx-wallet-sdk-ios'
    s.license          = { :type => 'Apache License 2.0', :file => 'LICENSE' }
    s.author           = { 'Immutable' => 'opensource@immutable.com' }
    s.source           = { :http => 'https://github.com/immutable/imx-wallet-sdk-ios/releases/download/v0.1.0/ImmutableXWalletSDK.zip' }
  
    s.cocoapods_version = '>= 1.10.0'
    s.ios.deployment_target = '13'
    s.swift_version = '5.7'

    s.vendored_frameworks = 'ImmutableXWalletSDK.xcframework'

    s.dependency 'Valet', '~> 4.1.3'
    s.dependency 'WalletConnectSwift', '~> 1.7.0'
    s.dependency 'ImmutableXCore', '~> 0.4.0'
  end