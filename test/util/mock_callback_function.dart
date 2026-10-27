import 'package:mockito/mockito.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

/// Helper to verify whether ChangeNotifier listeners are called.
class MockCallbackFunction extends Mock {
  void call();
}

class MockCallbackPoiFunction extends Mock {
  void call(RokasPOI? poi);
}

class MockCallbackSymbolFunction extends Mock {
  void call(SBBMapSymbol s);
}

class MockCallbackRokasIconFunction extends Mock {
  void call(SBBRokasIcon s);
}
