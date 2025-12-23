import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'fcm_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FcmService().init();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Push Notification',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MyHomePage(),
    );
  }
}

class AppState with ChangeNotifier {
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  final TextEditingController titleController = TextEditingController(text: 'sample');
  final TextEditingController contentController = TextEditingController(text: 'test content');
  final TextEditingController urlController = TextEditingController(text: 'http://google.com');

  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> get history => _history;

  AppState() {
    _loadHistory();
    _loadToken();
  }

  void _loadToken() async {
    _fcmToken = await FcmService().getToken();
    notifyListeners();
  }

  void refreshToken() {
    _loadToken();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getStringList('notification_history') ?? [];
    _history = historyString.map((h) => jsonDecode(h) as Map<String, dynamic>).toList();
    notifyListeners();
  }

  void clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_history');
    _history = [];
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notification API'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showHowToUseDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard('Your API KEY', appState.fcmToken ?? 'Loading...'),
            const SizedBox(height: 16),
            _buildInfoCard('Your API URL', 'http://xdroid.net/api/message?k=${appState.fcmToken ?? ''}&t=title&c=contents&u=http://Address-you-want-to-notice'),
            const SizedBox(height: 16),
            _buildTestForm(context, appState),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => appState.refreshToken(),
              icon: const Icon(Icons.refresh),
              label: const Text('REFRESH API KEY'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SelectableText(content, style: GoogleFonts.openSans(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildTestForm(BuildContext context, AppState appState) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Test Submission Form', style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: appState.fcmToken,
              decoration: const InputDecoration(labelText: 'k'),
              readOnly: true,
            ),
            TextFormField(
              controller: appState.titleController,
              decoration: const InputDecoration(labelText: 't'),
            ),
            TextFormField(
              controller: appState.contentController,
              decoration: const InputDecoration(labelText: 'c'),
            ),
            TextFormField(
              controller: appState.urlController,
              decoration: const InputDecoration(labelText: 'u'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification sent')),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('SUBMIT'),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  label: const Text('URL SHARE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showHowToUseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to use'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: [
              Text('Simple push notification receiver with easy REST API to send messages'),
              SizedBox(height: 16),
              Text('1. Make a GET / POST request via HTTP / HTTPS using the API Key displayed in the app'),
              SizedBox(height: 8),
              Text('2. The following parameters can be set'),
              Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text('k=API Key (required)\nt=title\nc=content\nu=URL to open when clicked'),
              ),
              SizedBox(height: 8),
              Text('3. API Key can be recreated'),
              SizedBox(height: 8),
              Text('4. You can check from the test submission form'),
              SizedBox(height: 8),
              Text('5. Sample request'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => appState.clearHistory(),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: appState.history.length,
        itemBuilder: (context, index) {
          final item = appState.history[index];
          final timestamp = DateTime.parse(item['timestamp']);
          final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(timestamp);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(item['title'], style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['body']),
                  if (item['url'] != null) Text(item['url'], style: const TextStyle(color: Colors.blue)),
                ],
              ),
              trailing: Text(formattedDate),
            ),
          );
        },
      ),
    );
  }
}
