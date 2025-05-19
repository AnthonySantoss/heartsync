import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerPage extends StatefulWidget {
  final Function(String) onScanned;

  const QRScannerPage({super.key, required this.onScanned});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController? cameraController;
  String _statusMessage = 'Verificando permissão da câmera...';
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    print('QRScannerPage: initState chamado'); // Debug
    _checkCameraPermission(); // Verifica permissão ao iniciar
  }

  Future<void> _checkCameraPermission() async {
    print('QRScannerPage: Verificando permissão da câmera'); // Debug
    var status = await Permission.camera.status;

    if (status.isGranted) {
      print('QRScannerPage: Permissão da câmera já concedida'); // Debug
      setState(() {
        _hasPermission = true;
        _statusMessage = 'Permissão concedida. Iniciando câmera...';
      });
      cameraController = MobileScannerController();
    } else if (status.isDenied) {
      print('QRScannerPage: Permissão não concedida, solicitando...'); // Debug
      status = await Permission.camera.request();
      if (status.isGranted) {
        print('QRScannerPage: Permissão da câmera concedida após solicitação'); // Debug
        setState(() {
          _hasPermission = true;
          _statusMessage = 'Permissão concedida. Iniciando câmera...';
        });
        cameraController = MobileScannerController();
      } else {
        print('QRScannerPage: Permissão da câmera negada'); // Debug
        setState(() {
          _statusMessage = 'Permissão da câmera negada. Não é possível escanear.';
        });
      }
    } else if (status.isPermanentlyDenied) {
      print('QRScannerPage: Permissão da câmera negada permanentemente'); // Debug
      setState(() {
        _statusMessage = 'Permissão da câmera negada permanentemente. Abra as configurações para conceder acesso.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permissão da câmera negada permanentemente. Abra as configurações para conceder acesso.'),
          action: SnackBarAction(
            label: 'Configurações',
            onPressed: () {
              print('QRScannerPage: Abrindo configurações do aplicativo'); // Debug
              openAppSettings();
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('QRScannerPage: Construindo widget'); // Debug
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            print('QRScannerPage: Botão de voltar pressionado'); // Debug
            Navigator.pop(context);
          },
        ),
      ),
      body: _hasPermission && cameraController != null
          ? Stack(
        children: [
          MobileScanner(
            controller: cameraController!,
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  print('QRScannerPage: QR Code escaneado: ${barcode.rawValue}'); // Debug
                  widget.onScanned(barcode.rawValue!);
                  Navigator.pop(context); // Fecha a tela após escanear
                  break;
                }
              }
            },
            errorBuilder: (context, error, child) {
              print('QRScannerPage: Erro ao acessar a câmera: $error'); // Debug
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Erro ao acessar a câmera: $error',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _checkCameraPermission,
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 18, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkCameraPermission,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}