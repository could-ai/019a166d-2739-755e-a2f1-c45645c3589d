import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'dart:async';
import 'dart:typed_data';
import '../models/aircraft.dart';
import '../widgets/aircraft_overlay.dart';
import '../widgets/pdf_map_viewer.dart';

class ADSBViewerScreen extends StatefulWidget {
  const ADSBViewerScreen({super.key});

  @override
  State<ADSBViewerScreen> createState() => _ADSBViewerScreenState();
}

class _ADSBViewerScreenState extends State<ADSBViewerScreen> {
  final PdfController _pdfController = PdfController(
    document: PdfDocument.openAsset('assets/maps/sample_map.pdf'),
  );

  List<Aircraft> _aircrafts = [];
  UsbPort? _port;
  StreamSubscription<Uint8List>? _dataSubscription;
  Timer? _dataLossTimer;
  bool _isConnected = false;
  String _connectionStatus = 'Disconnected';

  @override
  void initState() {
    super.initState();
    _initializeSDRConnection();
    _startDataLossDetection();
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _port?.close();
    _dataLossTimer?.cancel();
    _pdfController.dispose();
    super.dispose();
  }

  void _initializeSDRConnection() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isNotEmpty) {
      _port = await devices[0].create();
      bool openResult = await _port!.open();
      if (openResult) {
        await _port!.setDTR(true);
        await _port!.setRTS(true);
        _port!.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

        _dataSubscription = _port!.inputStream!.listen((Uint8List data) {
          _processADSData(data);
          _resetDataLossTimer();
        });

        setState(() {
          _isConnected = true;
          _connectionStatus = 'Connected to SDR';
        });
      }
    }
  }

  void _processADSData(Uint8List data) {
    // Placeholder for ADS-B data parsing
    // In a real implementation, this would parse ADS-B messages
    // For now, simulate aircraft data
    String dataString = String.fromCharCodes(data);
    if (dataString.contains('ADS-B')) {
      // Parse and update aircraft list
      setState(() {
        _aircrafts = _parseAircraftData(dataString);
      });
    }
  }

  List<Aircraft> _parseAircraftData(String data) {
    // Placeholder parsing logic
    // In reality, decode ADS-B messages properly
    return [
      Aircraft(
        id: 'ABC123',
        callsign: 'UAL456',
        type: 'B737',
        flightLevel: 350,
        squawk: '1234',
        speed: 450,
        position: Offset(100, 100),
        tagPosition: Offset(150, 50),
      ),
    ];
  }

  void _startDataLossDetection() {
    _dataLossTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_isConnected) {
        setState(() {
          _connectionStatus = 'Data Loss Detected';
          _isConnected = false;
        });
      }
    });
  }

  void _resetDataLossTimer() {
    _dataLossTimer?.cancel();
    _startDataLossDetection();
    if (!_isConnected) {
      setState(() {
        _connectionStatus = 'Connected to SDR';
        _isConnected = true;
      });
    }
  }

  void _onTagMoved(Aircraft aircraft, Offset newPosition) {
    setState(() {
      aircraft.tagPosition = newPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADS-B Tracker'),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.usb : Icons.usb_off),
            onPressed: _initializeSDRConnection,
            tooltip: _connectionStatus,
          ),
        ],
      ),
      body: Stack(
        children: [
          PDFMapViewer(pdfController: _pdfController),
          AircraftOverlay(
            aircrafts: _aircrafts,
            onTagMoved: _onTagMoved,
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                _connectionStatus,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
