import 'package:flutter/material.dart';
import 'package:metakeep_flutter_sdk/metakeep_flutter_sdk.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
  // Replace with your own Sepolia RPC endpoint from Alchemy
  static const String _rpcEndpoint = 'YOUR_SEPOLIA_RPC_URL_HERE';

  late final MetaKeep sdk;
  String? _ethAddress;
  String? _lastTxHash;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Replace with your own app ID from MetaKeep developer console
    sdk = MetaKeep("YOUR_APP_ID_HERE");
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  Future<String> _rpcCall(String method, List<dynamic> params) async {
    final rpcUrl = Uri.parse(_rpcEndpoint);
    final body = jsonEncode({
      "jsonrpc": "2.0",
      "method": method,
      "params": params,
      "id": 1
    });
    final resp = await http.post(
      rpcUrl,
      headers: {"content-type": "application/json"},
      body: body,
    );
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
    final m = jsonDecode(resp.body) as Map<String, dynamic>;
    if (m['error'] != null) {
      throw Exception('RPC error: ${m['error']}');
    }
    return m['result'] as String;
  }

  Future<void> _getWallet() async {
    setState(() => _busy = true);
    try {
      final dynamic res = await sdk.getWallet();
      final Map resMap = res as Map; // from platform channel
      final Map? wallet = resMap['wallet'] as Map?;
      setState(() {
        _ethAddress = wallet != null ? wallet['ethAddress'] as String? : null;
      });
    } catch (e) {
      setState(() {
        _ethAddress = 'Error: $e';
      });
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _signAndBroadcast() async {
    if (_ethAddress == null || _ethAddress!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Get wallet first')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      // Fetch correct nonce and gas price from RPC
      final String nonceHex = await _rpcCall(
        'eth_getTransactionCount',
        [_ethAddress, 'pending'],
      );
      final String gasPriceHex = await _rpcCall('eth_gasPrice', []);

      final tx = {
        "type": 2,
        "to": "0x97706df14a769e28ec897dac5ba7bcfa5aa9c444",
        // 0.001 ETH in wei = 1e15 = 0x38D7EA4C68000
        "value": "0x38D7EA4C68000",
        "nonce": nonceHex,
        "data": "0x",
        // Sepolia chainId
        "chainId": "0xaa36a7",
        // simple gas params for demo
        "gas": "0x5208", // 21000
        "maxFeePerGas": gasPriceHex,
        "maxPriorityFeePerGas": gasPriceHex,
      };

      final dynamic signed = await sdk.signTransaction(
        tx,
        'Send 0.001 Sepolia ETH',
      );

      final Map signedMap = signed as Map;
      final String? signedRaw = signedMap["signedRawTransaction"] as String?;
      if (signedRaw == null) {
        throw Exception('Invalid sign response: $signed');
      }

      final sendResult = await _rpcCall(
        'eth_sendRawTransaction',
        [signedRaw],
      );

      setState(() {
        _lastTxHash = sendResult;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _busy = false);
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
            Text('ETH Address: ${_ethAddress ?? '-'}'),
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
                  child: const Text('Send 0.001 ETH'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_lastTxHash != null) ...[
              Text('Tx Hash: $_lastTxHash'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _launchUrl(
                  'https://sepolia.etherscan.io/tx/${_lastTxHash!}',
                ),
                child: Text(
                  'Etherscan: https://sepolia.etherscan.io/tx/${_lastTxHash!}',
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
