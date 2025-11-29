import 'package:flutter/material.dart';
import 'package:kra_connect/kra_connect.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KRA Connect Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PinVerificationScreen(),
    );
  }
}

class PinVerificationScreen extends StatefulWidget {
  const PinVerificationScreen({super.key});

  @override
  State<PinVerificationScreen> createState() => _PinVerificationScreenState();
}

class _PinVerificationScreenState extends State<PinVerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  final KraClient _client = KraClient(
    config: KraConfig(
      apiKey: 'your-api-key-here',
      enableCache: true,
      enableDebugLogging: true,
    ),
  );

  PinVerificationResult? _result;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _client.close();
    super.dispose();
  }

  Future<void> _verifyPin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final result = await _client.verifyPin(_pinController.text.trim());

      setState(() {
        _result = result;
        _isLoading = false;
      });
    } on ValidationException catch (e) {
      setState(() {
        _errorMessage = 'Validation Error: ${e.message}';
        _isLoading = false;
      });
    } on AuthenticationException catch (e) {
      setState(() {
        _errorMessage = 'Authentication Error: ${e.message}';
        _isLoading = false;
      });
    } on NetworkException catch (e) {
      setState(() {
        _errorMessage = 'Network Error: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KRA PIN Verification'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter KRA PIN',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _pinController,
                      decoration: const InputDecoration(
                        labelText: 'PIN Number',
                        hintText: 'e.g., P051234567A',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: (_) => _verifyPin(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _verifyPin,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(_isLoading ? 'Verifying...' : 'Verify PIN'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Error Message
            if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Result Section
            if (_result != null) ...[
              Card(
                color: _result!.isValid
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _result!.isValid
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: _result!.isValid
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                            size: 32,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _result!.isValid ? 'Valid PIN' : 'Invalid PIN',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _result!.isValid
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_result!.isValid) ...[
                        _buildInfoRow('PIN Number', _result!.pinNumber),
                        _buildInfoRow('Taxpayer Name', _result!.taxpayerName ?? 'N/A'),
                        _buildInfoRow('Taxpayer Type', _result!.taxpayerType ?? 'N/A'),
                        _buildInfoRow('Status', _result!.status ?? 'N/A'),
                        if (_result!.registrationDate != null)
                          _buildInfoRow('Registration Date', _result!.registrationDate!),
                        if (_result!.taxOffice != null)
                          _buildInfoRow('Tax Office', _result!.taxOffice!),
                        if (_result!.businessActivity != null)
                          _buildInfoRow('Business Activity', _result!.businessActivity!),
                        const SizedBox(height: 8),
                        if (_result!.isActive)
                          Chip(
                            label: const Text('Active'),
                            backgroundColor: Colors.green.shade100,
                            avatar: const Icon(Icons.check, size: 16),
                          ),
                        if (_result!.isCompany)
                          Chip(
                            label: const Text('Company'),
                            backgroundColor: Colors.blue.shade100,
                            avatar: const Icon(Icons.business, size: 16),
                          ),
                        if (_result!.isIndividual)
                          Chip(
                            label: const Text('Individual'),
                            backgroundColor: Colors.purple.shade100,
                            avatar: const Icon(Icons.person, size: 16),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            // Cache Stats Section
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cache Statistics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<Map<String, dynamic>>(
                      future: Future.value(_client.getCacheStats()),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text('Loading...');
                        }

                        final stats = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Cache Size', '${stats['size']}'),
                            _buildInfoRow('Max Size', '${stats['max_size']}'),
                            _buildInfoRow('Utilization', '${stats['utilization']}%'),
                            _buildInfoRow('Valid Entries', '${stats['valid_entries']}'),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _client.clearCache();
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Cache cleared'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.clear_all),
                                label: const Text('Clear Cache'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
