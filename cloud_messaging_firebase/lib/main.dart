import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'fcm_send_service.dart';
import 'firebase_fcm_config.dart';
import 'firebase_messaging_config.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseFcmConfig().initConfig();
  // Register background handler first (required for Android background/terminated messages)
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // await FirebaseMessagingConfig().initConfig();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _fcmToken;
  bool _loadingToken = true;
  bool _sendingFcm = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    setState(() {
      _fcmToken = token;
      _loadingToken = false;
    });
  }

  Future<void> _showTestNotification() async {
    await FirebaseMessagingConfig.showTestNotification();
  }

  Future<void> _sendFcmToThisDevice() async {
    final token = _fcmToken;
    if (token == null || token.isEmpty) {
      _showSnackBar('No FCM token');
      return;
    }
    setState(() => _sendingFcm = true);
    try {
      await FcmSendService.send(
        deviceToken: token,
        title: 'From Flutter',
        body: 'Sent via service account (in-app)',
      );
      if (mounted) _showSnackBar('FCM sent');
    } on FcmSendException catch (e) {
      if (mounted) _showSnackBar('FCM error: ${e.statusCode} ${e.body}');
    } catch (e, st) {
      if (mounted) _showSnackBar('Error: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      if (mounted) setState(() => _sendingFcm = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Cloud Messaging Example',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadingToken ? null : _showTestNotification,
              icon: const Icon(Icons.notifications_active),
              label: const Text('Show test notification'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap to show a test notification (all in-app, no server).',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: (_loadingToken || _sendingFcm) ? null : _sendFcmToThisDevice,
              icon: _sendingFcm
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_sendingFcm ? 'Sending…' : 'Send FCM to this device'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Uses assets/money-manager-3a90b-e3ac185b8893.json to send a real FCM message.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text('FCM token:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _loadingToken ? 'Loading…' : (_fcmToken ?? 'No token'),
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
