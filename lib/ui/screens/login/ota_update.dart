import 'package:flutter/material.dart';
import 'package:sevanam_mobkol/services/config/config.dart';
import 'package:sevanam_mobkol/ui/constant/constant.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class OtaUpdatePage extends StatefulWidget {
  @override
  State<OtaUpdatePage> createState() => _OtaUpdatePageState();
}

class _OtaUpdatePageState extends State<OtaUpdatePage> {
  // Pindahkan ke dalam State, bukan global
  final _shorebirdUpdater = ShorebirdUpdater();

  // Ubah jadi late final
  late final bool _isShorebirdAvailable;

  bool downloading = false;
  bool updated = false;
  Patch? _currentPatch;

  @override
  void initState() {
    super.initState();

    // Set availability di initState
    _isShorebirdAvailable = _shorebirdUpdater.isAvailable;

    // Baca current patch
    _shorebirdUpdater.readCurrentPatch().then((currentPatch) {
      if (mounted) {
        setState(() => _currentPatch = currentPatch);
      }
    }).catchError((Object error) {
      debugPrint('Error reading current patch: $error');
    });

    // Auto check update saat page dibuka
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    if (!_isShorebirdAvailable) return;

    try {
      final status = await _shorebirdUpdater.checkForUpdate();

      if (!mounted) return;

      switch (status) {
        case UpdateStatus.outdated:
          // Ada update tersedia, tampilkan UI
          debugPrint('Update tersedia!');
          break;
        case UpdateStatus.upToDate:
          debugPrint('Sudah versi terbaru');
          break;
        case UpdateStatus.restartRequired:
          setState(() => updated = true);
          break;
        case UpdateStatus.unavailable:
          debugPrint('Update tidak tersedia');
          break;
      }
    } catch (error) {
      debugPrint('Error checking update: $error');
    }
  }

  Future<void> _downloadUpdate() async {
    if (!_isShorebirdAvailable) {
      _showErrorSnackbar('Shorebird tidak tersedia');
      return;
    }

    setState(() {
      downloading = true;
    });

    try {
      await _shorebirdUpdater.update();

      if (!mounted) return;

      setState(() {
        downloading = false;
        updated = true;
      });

      _showSuccessSnackbar('Update berhasil diunduh!');
    } on UpdateException catch (error) {
      if (!mounted) return;

      setState(() {
        downloading = false;
      });

      _showErrorSnackbar('Gagal mengunduh pembaharuan: ${error.message}');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        downloading = false;
      });

      _showErrorSnackbar('Terjadi kesalahan: $error');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget downloadingUpdate() {
    return Container(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 3),
            height: 14,
            width: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: accentColor,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Mengunduh pembaharuan...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget restartApp() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Text(
            '✓ Aplikasi berhasil diperbaharui. Silahkan restart aplikasi.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          if (_currentPatch != null)
            Text(
              'Patch version: ${_currentPatch!.number}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          Container(
            margin: EdgeInsets.only(top: 10),
            height: 50,
            child: primaryButton(
              onPress: () => Restart.restartApp(),
              title: 'Restart Aplikasi',
            ),
          ),
        ],
      ),
    );
  }

  Widget updateApp() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: primaryButton(
        onPress: _downloadUpdate,
        title: "Perbaharui",
      ),
    );
  }

  Widget primaryButton({
    void Function()? onPress,
    required String title,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, accentColor],
        ),
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black87.withOpacity(.2),
            offset: Offset(0.0, 5.0),
            blurRadius: 8.0,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPress,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 30,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/icon/logo.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          width: 70,
                          height: 70,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Perbaharui aplikasi anda ke versi terbaru',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 40,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Pembaharuan tersedia untuk aplikasi $mobileName. Lakukan pembaruan untuk meningkatkan pengalaman pengguna.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),
                      ],
                    ),
                  ),
                ),

                // UI berdasarkan kondisi
                if (!_isShorebirdAvailable)
                  Column(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orange, size: 48),
                      SizedBox(height: 12),
                      Text(
                        'Shorebird tidak tersedia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pastikan aplikasi di-build dengan mode release menggunakan shorebird release.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                else if (downloading)
                  downloadingUpdate()
                else if (updated)
                  restartApp()
                else
                  updateApp(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
