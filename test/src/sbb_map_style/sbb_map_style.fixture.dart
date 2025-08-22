import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

const brightId = 'bright';
const darkId = 'dark';
const aerialId = 'aerial';
const brightStyleURL = 'bright_uri';
const darkStyleURL = 'dark_uri';
const aerialStyleURL = 'aerial_uri';
const apiKey = 'bright_key';

const brightOnlyWithoutApiKey = SBBMapStyle.fromURL(id: brightId, brightStyleURL: brightStyleURL);
const brightOnlyWithApiKey = SBBMapStyle.fromURL(id: brightId, brightStyleURL: brightStyleURL, apiKey: apiKey);
const fullWithoutApiKey = SBBMapStyle.fromURL(id: darkId, brightStyleURL: brightStyleURL, darkStyleURL: darkStyleURL);
const fullWithApiKey = SBBMapStyle.fromURL(
  id: darkId,
  brightStyleURL: brightStyleURL,
  darkStyleURL: darkStyleURL,
  apiKey: apiKey,
);

const aerialWithApiKey = SBBMapStyle.fromURL(id: aerialId, brightStyleURL: aerialStyleURL, apiKey: apiKey);
