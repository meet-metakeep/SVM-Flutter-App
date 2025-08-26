import 'package:flutter/material.dart';
import 'package:metakeep_flutter_sdk/metakeep_flutter_sdk.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:solana/solana.dart' as solana;
import 'dart:convert' as convert;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetaKeep Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'MetaKeep Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Solana RPC endpoint
  static const String _rpcEndpoint = 'https://api.devnet.solana.com';

  late final MetaKeep sdk;
  String? _solanaAddress;
  String? _lastTxHash;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // TODO: Replace <YOUR_APP_ID> with your own app ID from MetaKeep developer console
    // Get your app ID from: https://console.metakeep.xyz
    sdk = MetaKeep("<YOUR_APP_ID>");
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
    }
  }



  Future<void> _getWallet() async {
    setState(() => _busy = true);
    try {
      final dynamic res = await sdk.getWallet();
      final Map resMap = res as Map;
      final Map? wallet = resMap['wallet'] as Map?;
      setState(() {
        _solanaAddress = wallet != null ? wallet['solAddress'] as String? : null;
      });
    } catch (e) {
      setState(() {
        _solanaAddress = 'Error: $e';
      });
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _signAndBroadcast() async {
    if (_solanaAddress == null || _solanaAddress!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Get wallet first')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      // Create a Solana transfer transaction
      final client = solana.RpcClient(_rpcEndpoint);
      
      // Get latest blockhash
      final latestBlockhash = await client.getLatestBlockhash();
      
      // Create a Solana transfer transaction with the specific recipient address
      final message = solana.Message.only(
        solana.SystemInstruction.transfer(
          fundingAccount: solana.Ed25519HDPublicKey.fromBase58(_solanaAddress!), // Use the wallet address from getWallet
          recipientAccount: solana.Ed25519HDPublicKey.fromBase58('BCf7PuGsv2yQFRJ9GATZafg4L4LrV6vkfYwmS3jVREvM'), // Specific recipient address
          lamports: 1000000, // 0.001 SOL (1 SOL = 1,000,000,000 lamports)
        ),
      );
      
      // Compile the message with the latest blockhash and fee payer
      final compiledMessage = message.compile(
        recentBlockhash: latestBlockhash.value.blockhash,
        feePayer: solana.Ed25519HDPublicKey.fromBase58(_solanaAddress!), // Use the wallet address as fee payer
      );
      
      // Serialize the compiled message
      final serializedTransactionMessage = compiledMessage.toByteArray();
      final hexString = '0x${serializedTransactionMessage.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('')}';
      
      // Sign transaction using MetaKeep SDK
      final dynamic signed = await sdk.signSolanaTransaction(
        hexString,
        'transfer 0.001 SOL',
      );

      final Map signedMap = signed as Map;
      final String? signature = signedMap["signature"] as String?;
      if (signature == null) {
        throw Exception('Invalid sign response: $signed');
      }

      // Broadcast the signed transaction to Solana devnet
      final String? signedRawTransaction = signedMap["signedRawTransaction"] as String?;
      if (signedRawTransaction == null) {
        throw Exception('No signed transaction data received');
      }

      // Remove the "0x" prefix and convert to base64 for Solana RPC
      final String rawTxHex = signedRawTransaction.startsWith('0x') 
          ? signedRawTransaction.substring(2) 
          : signedRawTransaction;
      
      final List<int> txBytes = [];
      for (int i = 0; i < rawTxHex.length; i += 2) {
        txBytes.add(int.parse(rawTxHex.substring(i, i + 2), radix: 16));
      }
      
      final String base64Tx = convert.base64Encode(txBytes);
      
      // Send transaction to Solana devnet
      final String txHash = await client.sendTransaction(
        base64Tx,
      );

      setState(() {
        _lastTxHash = txHash;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Solana Address: ${_solanaAddress ?? '-'}'),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _busy ? null : _getWallet,
                  child: const Text('Get Wallet'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _busy ? null : _signAndBroadcast,
                  child: const Text('Send 0.001 SOL'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_lastTxHash != null) ...[
              Text('Tx Hash: $_lastTxHash'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _launchUrl(
                  'https://solscan.io/tx/${_lastTxHash!}?cluster=devnet',
                ),
                child: Text(
                  'Solscan Devnet: https://solscan.io/tx/${_lastTxHash!}?cluster=devnet',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
