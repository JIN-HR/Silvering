import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocode/geocode.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  StreamSocket streamSocket = StreamSocket();
  LocationService locationService = LocationService();
  late GoogleMapController mapController;
  final LatLng initLocation =
  const LatLng(37.5759, 126.9768); //연결 안됐을때 초기 위치 (경복궁)
  late Marker userMarker;
  StreamSubscription<Position>? positionStreamSubscription;
  String addressText = "위치를 가져오는 중...";

  @override
  void initState() {
    super.initState();
    locationService.initSocket();
    userMarker = Marker(
      markerId: MarkerId('userLocation'),
      position: initLocation,
    );
    _startLocationStream();
  }

  @override
  // 실시간 위치 stream 시작
  Future<void> _startLocationStream() async {
    final hasPermission = await locationService.handlePermission();
    if (!hasPermission) return;

    positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) async {
      _updateMarkerPosition(position);
      Address address = await _updateAddress(position);
      setState(() {
        addressText = "${address.city}, ${address.streetAddress}";
      });
    });
  }

  //marker 업데이트
  void _updateMarkerPosition(Position position) {
    setState(() {
      userMarker = Marker(
        markerId: MarkerId('userLocation'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(title: 'Current Location'),
      );
      mapController.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
    });
  }

  //adress 업데이트
  Future<Address> _updateAddress(Position position) async {
    return await GeoCode().reverseGeocoding(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('피보호자 위치 확인'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: initLocation,
                zoom: 15.0,
              ),
              markers: {userMarker},
              mapType: MapType.normal,
            ),
          ),
          // Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: Text(
          //       addressText,
          //     ))
        ],
      ),
    );
  }
}

//피보호자-보호자 소켓 연결
class StreamSocket {
  final _socketResponse = StreamController<dynamic>();
  void Function(dynamic) get addResponse => _socketResponse.sink.add;
  Stream<dynamic> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}

class LocationService {
  IO.Socket? socket;

  void initSocket() {
    socket = IO.io(
        'http://0.0.0.0:5000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .build());

    socket!.on('connect_error', (data) {
      print('Connection Error: $data');
    });

    socket!.on('connect', (_) {
      print('Socket connected');
    });

    socket!.on('disconnect', (_) {
      print('Socket disconnected');
    });
  }

  Future<bool> handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied');
        return false;
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return false;
      }
    }
    return true;
  }

/*Future<Position> locationUpdate() async {
    final hasPermission = await handlePermission();
    if (!hasPermission)
      return Position(
        latitude: 0.0,
        longitude: 0.0,
        timestamp: DateTime.now(), // timestamp 추가
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

    final Position position = await Geolocator.getCurrentPosition();
    if (socket != null && socket!.connected) {
      socket!.emit('location_update',
          {'latitude': position.latitude, 'longitude': position.longitude});
    }
    print(
        'Updated position: Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    return position;
  }*/
}