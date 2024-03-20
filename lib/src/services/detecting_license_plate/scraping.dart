import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

String formatDate(int val) {
  var date = DateTime.fromMillisecondsSinceEpoch(val);
  return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
}

class ScrappingData {
  static Future<String> scrappingData(String licensePlate) async {
    var licensePlates = licensePlate;
    var baseUrl = 'https://inspectorulpadurii.ro/api/aviz';
    var latestCode;

    var response =
        await http.get(Uri.parse('$baseUrl/locations?nr=$licensePlates'));
    var data = jsonDecode(response.body);

    var codes = data['codAviz'];
    if (codes == null || codes.isEmpty) {
      return 'Invalid Number!';
    } else {
      latestCode = codes.last;

      var resp2 = await http.get(Uri.parse('$baseUrl/$latestCode'));
      var data2 = jsonDecode(resp2.body);
      var volume = data2['volum']['total'];
      //var validFrom = formatDate(data2['valabilitate']['emitere']);
      //var validTo = formatDate(data2['valabilitate']['finalizare']);

      return volume.toString();
    }
  }
}
