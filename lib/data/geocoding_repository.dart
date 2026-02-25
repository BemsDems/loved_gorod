import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingRepository {
  static const String _dadataApiKey =
      "edbc3369aa11acc7fd55f510c1224357e2e45b25";
  static const String _dadataSecretKey =
      "6f3b966cb58f3d77ee5afa87824b1f7c6049cfd8";

  static Future<String> getAddress(LatLng point) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}&zoom=18&addressdetails=1&accept-language=ru', // Добавил язык RU
      );
      log(point.toString());
      final response = await http.get(
        url,
        headers: {'User-Agent': 'com.belovedcity.app'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addressData = data['address'];

        if (addressData == null) return "Адрес не определен";

        List<String> parts = [];

        if (addressData['state'] != null) parts.add(addressData['state']);

        final city =
            addressData['city'] ??
            addressData['town'] ??
            addressData['village'] ??
            addressData['hamlet'];
        if (city != null) parts.add(city);

        final road =
            addressData['road'] ??
            addressData['pedestrian'] ??
            addressData['highway'];
        if (road != null) parts.add(road);

        if (addressData['house_number'] != null) {
          parts.add('д. ${addressData['house_number']}');
        }

        if (parts.isEmpty) {
          return data['display_name'] ?? "Адрес не найден";
        }

        return parts.join(', ');
      } else {
        return "Ошибка сервера карт (${response.statusCode})";
      }
    } catch (e) {
      return "Ошибка сети: $e";
    }
  }

  static Future<LatLng?> getCoordinates(String rawAddress) async {
    try {
      final url = Uri.parse("https://cleaner.dadata.ru/api/v1/clean/address");

      // DaData ожидает список строк ["адрес"]
      final body = json.encode([rawAddress]);

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_dadataApiKey",
          "X-Secret": _dadataSecretKey,
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final result = data[0];

          // geo_lat и geo_lon - это точные координаты дома
          final latStr = result['geo_lat'];
          final lonStr = result['geo_lon'];

          // Проверяем "qc_geo" (код качества координат).
          // 0 — точные координаты дома
          // 1 — ближайший дом
          // 2 — улица
          // 3 — населенный пункт
          // 4 — город

          if (latStr != null && lonStr != null) {
            final lat = double.tryParse(latStr);
            final lon = double.tryParse(lonStr);

            if (lat != null && lon != null) {
              log("DaData нашла: ${result['result']} ($lat, $lon)");
              return LatLng(lat, lon);
            }
          }
        }
      } else {
        log("Ошибка DaData: ${response.statusCode}");
      }
    } catch (e) {
      log("Ошибка сети: $e");
    }
    return null;
  }
}
