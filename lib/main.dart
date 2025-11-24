import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:typed_data'; // For Vibration

void main() {
  // 1. INITIALIZE NOTIFICATIONS (Clean & Simple)
  AwesomeNotifications().initialize(
    null, // default app icon
    [
      NotificationChannel(
        channelKey: 'task_channel',
        channelName: 'Task Notifications',
        channelDescription: 'Notification channel for scheduled tasks',
        
        // 🔥 HACKER COLORS
        defaultColor: Colors.greenAccent,
        ledColor: Colors.white,
        
        // 🚨 ALARM BEHAVIOR (System Default Sound)
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500]), // Dhak-Dhak pattern
      )
    ],
    debug: false,
  );

  runApp(const TaskAlertApp());
}

class TaskAlertApp extends StatelessWidget {
  const TaskAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskAlert',
      debugShowCheckedModeBanner: false,

      // 🔥 DARK HACKER THEME 🔥
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212), // Pitch Black
        
        colorScheme: const ColorScheme.dark(
          primary: Colors.greenAccent,
          secondary: Colors.green,
          surface: Color(0xFF1E1E1E),
          onSurface: Colors.greenAccent,
        ),

        // INPUT FIELD STYLING
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(
            color: Colors.greenAccent, 
            fontWeight: FontWeight.w900, 
            fontSize: 16,
          ),
          hintStyle: TextStyle(
            color: Colors.grey, 
            fontWeight: FontWeight.bold
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.greenAccent, width: 3.0),
          ),
          prefixIconColor: Colors.greenAccent,
        ),

        // GLOBAL TEXT STYLING
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Colors.greenAccent, 
            fontFamily: 'Courier', 
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          titleLarge: TextStyle(
            color: Colors.greenAccent, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 1.5,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _taskController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _checkNotificationPermissions();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _checkNotificationPermissions() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.greenAccent,
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.greenAccent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _scheduleAlarm() async {
    // VALIDATION
    if (_taskController.text.isEmpty || _selectedTime == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ACCESS DENIED: INPUT MISSING ❌"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // CREATE ALARM (Standard Logic)
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'task_channel',
        title: '🚨 SYSTEM ALERT 🚨',
        body: _taskController.text,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Alarm,
        autoDismissible: false, 
        fullScreenIntent: true,
        color: Colors.greenAccent,
        backgroundColor: Colors.black,
      ),
      schedule: NotificationCalendar(
        hour: _selectedTime!.hour,
        minute: _selectedTime!.minute,
        second: 0,
        millisecond: 0,
        repeats: false,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );

    // SUCCESS FEEDBACK
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("TASK SET ✅"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() {
      _taskController.clear();
      _selectedTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TASK ALERT"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.greenAccent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            height: 2.0,
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              boxShadow: [
                BoxShadow(color: Colors.greenAccent, blurRadius: 10, spreadRadius: 1)
              ],
            ),
          ),
        ),
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "> ENTER TASK",
              style: TextStyle(fontSize: 14, letterSpacing: 2.0, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            // TASK INPUT
            TextField(
              controller: _taskController,
              style: const TextStyle(
                color: Colors.greenAccent, 
                fontWeight: FontWeight.w900, 
                fontSize: 20,
              ),
              cursorColor: Colors.greenAccent,
              decoration: const InputDecoration(
                labelText: "TASK",
                hintText: "e.g. get milk at 3",
                prefixIcon: Icon(Icons.terminal),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // TIME DISPLAY BOX
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0x8069F0AE), width: 2), 
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Color(0x1A69F0AE), blurRadius: 10)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "T-MINUS (TIME)",
                        style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedTime == null
                            ? "-- : --"
                            : _selectedTime!.format(context),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.greenAccent,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.timer, color: Colors.black),
                    label: const Text(
                      "SET TIME", 
                      style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // EXECUTE BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scheduleAlarm,
        icon: const Icon(Icons.code, color: Colors.black),
        label: const Text(
          "SET TASK", 
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)
        ),
        backgroundColor: Colors.greenAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}