import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
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

    // Minta izin notifikasi biasa (Android 13+)
    try {
      await androidImpl?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('Gagal minta izin notifikasi: $e');
    }

    // Minta izin exact alarm (Android 12+) supaya notifikasi jam 9 pagi
    // benar-benar presisi, bukan cuma "sekitar" jam segitu.
    // Ini akan membuka dialog/Settings sistem kalau memang perlu.
    try {
      await androidImpl?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint('Gagal minta izin exact alarm: $e');
    }

    final IOSFlutterLocalNotificationsPlugin? iosImpl =
        _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    try {
      await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('Gagal minta izin notifikasi iOS: $e');
    }
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

    // Cek apakah exact alarm benar-benar boleh dipakai sekarang.
    // Kalau belum (user belum approve / OEM membatasi), otomatis
    // fallback ke inexact supaya tetap terjadwal, cuma waktunya
    // sedikit lebih longgar (biasanya tetap dekat dengan target).
    final AndroidFlutterLocalNotificationsPlugin? androidImpl =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    bool bolehExact = false;
    try {
      bolehExact = await androidImpl?.canScheduleExactNotifications() ?? false;
    } catch (e) {
      debugPrint('Gagal cek izin exact alarm, pakai inexact: $e');
      bolehExact = false;
    }

    try {
      await _plugin.zonedSchedule(
        id,
        'Tagihan $nama akan jatuh tempo besok',
        'Jangan lupa bayar Rp $harga sebelum tanggal ${tanggalJatuhTempo.day}/${tanggalJatuhTempo.month}.',
        waktuTz,
        detail,
        androidScheduleMode:
            bolehExact
                ? AndroidScheduleMode.exactAllowWhileIdle
                : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Fallback terakhir: kalau exact tetap gagal karena alasan lain,
      // paksa coba lagi dengan inexact supaya notifikasi tetap terjadwal.
      debugPrint('zonedSchedule exact gagal, coba inexact: $e');
      try {
        await _plugin.zonedSchedule(
          id,
          'Tagihan $nama akan jatuh tempo besok',
          'Jangan lupa bayar Rp $harga sebelum tanggal ${tanggalJatuhTempo.day}/${tanggalJatuhTempo.month}.',
          waktuTz,
          detail,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e2) {
        debugPrint('Gagal total menjadwalkan notifikasi: $e2');
      }
    }
  }

  Future<void> batalkanPengingat(String nama, DateTime tanggal) async {
    if (kIsWeb) return;

    final int id = _buatId(nama, tanggal);
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('Gagal membatalkan notifikasi: $e');
    }
  }
}
