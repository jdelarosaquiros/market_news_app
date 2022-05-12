import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/*
 * This class makes a connection to and gets data from the passed url.
 */

class NetworkHelper {

  final String url;
  NetworkHelper({required this.url});

  Future getData() async {

    http.Response response = await http.get(Uri.parse(url));

    if(response.statusCode == 200){
      String data = response.body;
      return jsonDecode(data);
    } else {
      if (kDebugMode) {
        print("Error ${response.statusCode}");
      }
      throw Exception("Error ${response.statusCode}");
    }
  }
}