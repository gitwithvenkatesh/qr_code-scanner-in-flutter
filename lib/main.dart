import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner',
      debugShowCheckedModeBanner: false,
      home: const QRScanner(),
    );
  }
}

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool isScanCompleted = false;
  final MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void closeScreen() {
    setState(() {
      isScanCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade900,
        leading: IconButton(
          style: ButtonStyle(
            iconSize: MaterialStateProperty.all(30.0),
            foregroundColor: MaterialStateProperty.all(Colors.amber.shade900),
            backgroundColor: MaterialStateProperty.all(Colors.white70),
          ),
          onPressed: () {},
          icon: const Icon(Icons.qr_code_scanner),
        ),
        centerTitle: true,
        title: const Text(
          "QR Scanner",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isFlashOn = !isFlashOn;
              });
              cameraController.toggleTorch();
            },
            icon: Icon(Icons.flash_on),
            color: isFlashOn ? Colors.white : Colors.black,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isFrontCamera = !isFrontCamera;
              });
              cameraController.switchCamera();
            },
            icon: Icon(
              Icons.flip_camera_android,
              color: isFrontCamera ? Colors.white : Colors.black,
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Place the QR code in the designated area",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Let the scan do the magic - It starts on its own!",
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  MobileScanner(
                    controller: cameraController,
                    allowDuplicates: false,
                    onDetect: (barcode, args) {
                      if (!isScanCompleted) {
                        setState(() {
                          isScanCompleted = true;
                        });
                        String code = barcode.rawValue ?? "---";
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return QRResultScreen(
                                result: code,
                                closeScreen: closeScreen,
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                  QRScannerOverlay(
                    overlayColor: Colors.black26,
                    borderColor: Colors.amber.shade500,
                    borderRadius: 20,
                    borderStrokeWidth: 10,
                    scanAreaHeight: 250,
                    scanAreaWidth: 250,
                  )
                ],
              ),
            ),
            const Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "| Scan properly to see results |",
                    style: TextStyle(color: Colors.amber, fontSize: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QRResultScreen extends StatelessWidget {
  final String result;
  final VoidCallback closeScreen;

  const QRResultScreen(
      {Key? key, required this.result, required this.closeScreen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code Result"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            closeScreen();
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Text(
          result,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
