import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return;

    tzdata.initializeTimeZones();

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    final AndroidFlutterLocalNotificationsPlugin? androidImpl =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidImpl?.requestNotificationsPermission();

    final IOSFlutterLocalNotificationsPlugin? iosImpl =
        _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);
  }

  int _buatId(String nama, DateTime tanggal) {
    return ('$nama${tanggal.toIso8601String()}').hashCode & 0x7fffffff;
  }

  Future<void> jadwalkanPengingat({
    required String nama,
    required int harga,
    required DateTime tanggalJatuhTempo,
  }) async {
    if (kIsWeb) return;

    final int id = _buatId(nama, tanggalJatuhTempo);

    final DateTime waktuNotifikasi = DateTime(
      tanggalJatuhTempo.year,
      tanggalJatuhTempo.month,
      tanggalJatuhTempo.day - 1,
      9,
      0,
    );

    if (waktuNotifikasi.isBefore(DateTime.now())) {
      return;
    }

    final tz.TZDateTime waktuTz = tz.TZDateTime.from(waktuNotifikasi, tz.local);

    const AndroidNotificationDetails androidDetail = AndroidNotificationDetails(
      'saku_langganan_channel',
      'Pengingat Tagihan',
      channelDescription: 'Pengingat H-1 sebelum tagihan langganan jatuh tempo',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails detail = NotificationDetails(
      android: androidDetail,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      'Tagihan $nama akan jatuh tempo besok',
      'Jangan lupa bayar Rp $harga sebelum tanggal ${tanggalJatuhTempo.day}/${tanggalJatuhTempo.month}.',
      waktuTz,
      detail,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> batalkanPengingat(String nama, DateTime tanggal) async {
    if (kIsWeb) return;

    final int id = _buatId(nama, tanggal);
    await _plugin.cancel(id);
  }
}
