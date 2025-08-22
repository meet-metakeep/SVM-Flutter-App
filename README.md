# MetaKeep Flutter Demo

Flutter Android app demonstrating MetaKeep SDK integration for wallet operations and transaction signing.

![MetaKeep Demo App Screenshot](metakeep_demo_screenshot.png)

*Screenshot showing the app interface with wallet address, transaction hash, and Etherscan link*

## Prerequisites

- Flutter SDK installed
- Android device or emulator (API level 26+)
- MetaKeep developer account
- Alchemy account for Sepolia testnet RPC

## Setup

### 1. Get MetaKeep App ID
- Sign up at [MetaKeep Developer Console](https://console.metakeep.xyz/)
- Create a new app and copy the App ID

### 2. Get Sepolia RPC URL
- Sign up at [Alchemy](https://www.alchemy.com)
- Create a new app for Sepolia testnet
- Copy the HTTP URL from your app dashboard

### 3. Configure the App
- Open `flutter_txn/lib/main.dart`
- Replace `YOUR_APP_ID_HERE` with your MetaKeep App ID
- Replace `YOUR_SEPOLIA_RPC_URL_HERE` with your Alchemy Sepolia RPC URL

### 4. Install Dependencies
```bash
cd flutter_txn
flutter pub get
```

### 5. Run the App
```bash
flutter run
```

## Features

- **Get Wallet**: Retrieves user's wallet addresses (ETH, SOL, EOS)
- **Sign Transaction**: Signs and broadcasts 0.001 ETH transaction to Sepolia testnet
- **Clickable Etherscan Link**: Direct link to view transaction on Etherscan

## SDK Usage

### Import
```dart
import 'package:metakeep_flutter_sdk/metakeep_flutter_sdk.dart';
```

### Initialize
```dart
final sdk = MetaKeep("YOUR_APP_ID_HERE");
```

### Get Wallet
```dart
final dynamic res = await sdk.getWallet();
final Map resMap = res as Map;
final Map? wallet = resMap['wallet'] as Map?;
final String? ethAddress = wallet?['ethAddress'] as String?;
```

### Sign Transaction
```dart
final tx = {
  "type": 2,
  "to": "0x...",
  "value": "0x...",
  "nonce": "0x...",
  "chainId": "0xaa36a7", // Sepolia
  "gas": "0x5208",
  "maxFeePerGas": "0x...",
  "maxPriorityFeePerGas": "0x..."
};

final dynamic signed = await sdk.signTransaction(tx, 'Transaction reason');
final String? signedRaw = signed['signedRawTransaction'] as String?;
```

## Android Configuration

The app includes necessary Android configuration:
- `minSdkVersion` set to 26
- MetaKeep manifest placeholders configured
- Deep link intent-filter for MetaKeep callbacks
- Internet permission enabled

## Testing

1. Get wallet address using "Get Wallet" button
2. Ensure wallet has Sepolia ETH for gas fees
3. Use "Send 0.001 ETH" to sign and broadcast transaction
4. Click Etherscan link to verify transaction on blockchain
