<div align="center">

# 📱 SakuLangganan

**Pantau semua langgananmu, jangan biarkan tagihan bikin kaget.**

Streaming, musik, hingga aplikasi produktivitas — kelola semuanya dalam satu tempat, lengkap dengan pengingat sebelum jatuh tempo, biar saldo rekeningmu nggak terpotong otomatis tanpa disadari.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Live Demo](https://img.shields.io/badge/Demo-Live-4b41e1?style=for-the-badge)](https://saku-langganan.vercel.app)

[Demo](https://saku-langganan.vercel.app) · [Laporkan Bug](../../issues) · [Ajukan Fitur](../../issues)

</div>

---

## 📖 Tentang SakuLangganan

Di era digital, kita gampang banget "kelupaan" udah punya berapa banyak langganan aktif — Netflix, Spotify, Notion, Adobe, gym, sampai aplikasi produktivitas lainnya. Tanpa disadari, total tagihan bulanan bisa membengkak dan saldo rekening terpotong otomatis tanpa persiapan.

**SakuLangganan** hadir sebagai solusi sederhana: satu aplikasi untuk mencatat, memantau, dan mengingatkan semua langgananmu — supaya kamu selalu tahu ke mana uangmu pergi setiap bulan. Semua data tersimpan langsung di perangkat kamu, jadi tetap aman dan bisa diakses meski aplikasi ditutup atau offline.

## ✨ Fitur Utama

| Fitur | Deskripsi |
|---|---|
| 💰 **Ringkasan Total Biaya** | Pantau total pengeluaran langganan tiap bulan secara sekilas |
| 🔔 **Pengingat Jatuh Tempo** | Dapatkan pengingat H-1 sebelum tagihan jatuh tempo, biar saldo nggak kepotong tiba-tiba |
| 📅 **Tampilan Kalender** | Lihat semua tagihan dalam bentuk kalender bulanan, tap tanggal untuk melihat detailnya |
| 🔄 **Deteksi & Perbarui Periode Otomatis** | Sistem otomatis mendeteksi dan memperbarui tagihan bulanan/tahunan yang sudah lewat |
| ✏️ **Edit & Kelola Tagihan** | Tap tagihan untuk mengedit, atau geser untuk menghapus |
| 💾 **Data Tersimpan Otomatis** | Data tagihan tersimpan langsung di perangkat, aman meski aplikasi ditutup |
| 📱 **Cross-Platform** | Dibangun dengan Flutter, bisa berjalan di Android, iOS, dan Web dari satu basis kode |

> Punya ide fitur lain? Jangan ragu buka [issue](../../issues) atau kirim pull request!

## 🖼️ Tampilan Aplikasi

<div align="center">
  <img src="docs/screenshot-1.png" width="250" alt="Dashboard SakuLangganan" />
  <img src="docs/screenshot-2.png" width="250" alt="Detail Langganan" />
  <img src="docs/screenshot-3.png" width="250" alt="Pengingat Jatuh Tempo" />
</div>

*(Ganti gambar di atas dengan screenshot asli aplikasimu di folder `docs/`)*

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev) — satu basis kode untuk Android, iOS, dan Web
- **Bahasa:** [Dart](https://dart.dev)
- **Deployment (Web):** [Vercel](https://vercel.com)

## 🚀 Memulai

### Prasyarat

Pastikan sudah menginstal:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi stabil terbaru)
- Editor seperti VS Code atau Android Studio dengan plugin Flutter & Dart

### Instalasi

```bash
# Clone repository ini
git clone https://github.com/[username-kamu]/saku-langganan.git
cd saku-langganan

# Install dependencies
flutter pub get

# Jalankan di emulator/device
flutter run

# Atau jalankan versi web
flutter run -d chrome
```

### Build untuk Production

```bash
# Android (APK)
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📂 Struktur Proyek

```
saku-langganan/
├── lib/
│   ├── main.dart          # Entry point aplikasi
│   ├── models/             # Model data (Langganan, Kategori, dll)
│   ├── screens/             # Halaman-halaman UI
│   ├── widgets/             # Komponen UI yang reusable
│   └── services/             # Logika bisnis & penyimpanan data
├── assets/                    # Ikon, gambar, font
├── docs/                        # Screenshot & dokumentasi
└── pubspec.yaml
```

*(Sesuaikan struktur di atas dengan struktur folder proyekmu yang sebenarnya)*

## 🗺️ Roadmap

- [ ] Export ringkasan pengeluaran ke PDF/Excel
- [ ] Sinkronisasi data lintas perangkat (cloud backup)
- [ ] Widget home screen untuk pengingat cepat
- [ ] Mode gelap/terang
- [ ] Dukungan multi-mata uang

## 🤝 Kontribusi

Kontribusi sangat terbuka! Untuk berkontribusi:

1. Fork repository ini
2. Buat branch fitur baru (`git checkout -b fitur/nama-fitur`)
3. Commit perubahanmu (`git commit -m 'Menambahkan fitur X'`)
4. Push ke branch (`git push origin fitur/nama-fitur`)
5. Buka Pull Request

## 📄 Lisensi

Didistribusikan di bawah lisensi MIT. Lihat `LICENSE` untuk info lebih lanjut.

## 👤 Kontak

Dibuat oleh **[Kemal Pramayuda]**
- Demo: [saku-langganan.vercel.app](https://saku-langganan.vercel.app)

---

<div align="center">

Kalau proyek ini membantu, jangan lupa beri ⭐ ya!

</div>
