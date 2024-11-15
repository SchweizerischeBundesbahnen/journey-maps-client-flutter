## Simple Map

```dart
class StandardMapRoute extends StatelessWidget {
  const StandardMapRoute({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SBBHeader(title: 'Standard'),
      body: SBBMap(
        isMyLocationEnabled: true,
        mapStyler: SBBRokasMapStyler.full(), // API key in ENV var
      ),
    );
  }
}
```

## Focus map on device position after build

Allows focusing the map directly on device position after the widget is built.
To use a lower zoom level, add an initialCameraPosition.

```dart
const _bern = SBBCameraPosition(target: LatLng(46.947456, 7.451123), zoom: 13.0)

class StandardMapRoute extends StatelessWidget {
  const StandardMapRoute({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SBBHeader(title: 'Standard'),
      body: SBBMap(
        isMyLocationEnabled: true,
        mapStyler: SBBRokasMapStyler.full(), // API key in ENV var
        initialCameraPosition: _bern, // specifying this will have the map on a smaller zoom level from beginning
        onMapLocatorAvailable: (locator) => locator.trackDeviceLocation(),
      ),
    );
  }
}
```