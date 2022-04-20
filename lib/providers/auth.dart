import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return _token != null;
  }

  String? get Token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) return _token;
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDKFqMHBBqev6L-xESZRxJtSzaasWD_iXw');
    try {
      final res = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));

      final resData = json.decode(res.body);

      if (resData['error'] != null) {
        throw HttpException(resData['error']['message']);
      }
      _token = resData['idToken'];
      _userId = resData['localId'];
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(resData['expiresIn'])));

      autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();

      String userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate?.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('userData')) {
      return false;
    }

    final extractedData =
        json.decode(prefs.getString('userData') as String) as Map<String, dynamic>;

    final expiryDate = DateTime.parse(extractedData['expiryDate'] as String);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedData['token'] ;
    _userId = extractedData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();

    autoLogout();
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    _token = null;
    _userId = null;
    _expiryDate = null;

    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    prefs.clear();
  }

    void autoLogout(){
      if (_authTimer != null) {
        _authTimer!.cancel();
      }
      final timeToExpiry=_expiryDate!.difference(DateTime.now()).inSeconds;
      _authTimer=Timer(Duration(seconds: timeToExpiry), logout);
    }
}
