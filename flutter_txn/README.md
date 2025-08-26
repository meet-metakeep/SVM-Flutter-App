# MetaKeep Solana Transaction App

A Flutter application that demonstrates how to integrate with MetaKeep SDK for Solana blockchain transactions.

## Features

- **Solana Wallet Integration**: Retrieve Solana wallet addresses using MetaKeep SDK
- **Transaction Creation**: Create and serialize Solana transfer transactions
- **Transaction Signing**: Sign transactions using MetaKeep's secure signing service
- **Devnet Broadcasting**: Broadcast signed transactions to Solana devnet
- **Transaction Tracking**: View transaction details on Solscan devnet explorer

## Configuration

### App ID
** You must replace the placeholder with your own MetaKeep App ID**

The app currently uses a placeholder: `<YOUR_APP_ID>`

**To get your App ID:**
1. Go to [console.metakeep.xyz](https://console.metakeep.xyz)
2. Sign in to your MetaKeep developer account
3. Create a new app or select an existing one
4. Copy your App ID from the dashboard
5. Replace `<YOUR_APP_ID>` in the following files:
   - `lib/main.dart` (line ~50)
   - `android/app/build.gradle.kts` (line ~35)

### Solana RPC Endpoint
- **Devnet RPC**: `https://api.devnet.solana.com`
- **Network**: Solana Devnet

### Recipient Address
The app is configured to send transactions to: `BCf7PuGsv2yQFRJ9GATZafg4L4LrV6vkfYwmS3jVREvM`

### Key Components

1. **Wallet Management**: Retrieves Solana wallet addresses via MetaKeep SDK
2. **Transaction Builder**: Creates Solana transfer transactions with proper instruction structure
3. **Transaction Signing**: Uses MetaKeep SDK to sign transactions securely
4. **Network Broadcasting**: Sends signed transactions to Solana devnet
5. **Transaction Explorer**: Links to Solscan devnet for transaction verification

### Transaction Flow

1. **Get Wallet**: Retrieve Solana wallet address from MetaKeep SDK
2. **Create Transaction**: Build Solana transfer transaction with recipient and amount
3. **Serialize**: Convert transaction to hex format for MetaKeep signing
4. **Sign**: Use MetaKeep SDK to sign the transaction
5. **Broadcast**: Send signed transaction to Solana devnet
6. **Track**: View transaction on Solscan devnet explorer

### Setup
1. Clone the repository
2. Navigate to `flutter_txn` directory
3. **Configure MetaKeep App ID:**
   - Get your App ID from [console.metakeep.xyz](https://console.metakeep.xyz)
   - Replace `<YOUR_APP_ID>` in `lib/main.dart` (line ~50)
   - Replace `<YOUR_APP_ID>` in `android/app/build.gradle.kts` (line ~35)
4. Run `flutter pub get` to install dependencies
5. Ensure MetaKeep SDK is properly configured
6. Run `flutter run` to launch the app


## Solana Network

- **Network**: Devnet (for development and testing)
- **Explorer**: Solscan Devnet
- **RPC Endpoint**: `https://api.devnet.solana.com`
- **Transaction Type**: SOL Transfer (0.001 SOL)

## License

This project is for demonstration purposes. Please refer to MetaKeep and Solana documentation for production use.
