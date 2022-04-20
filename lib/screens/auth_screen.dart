import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/http_exception.dart';
import '../providers/auth.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key?key}) : super(key: key);

  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Color.fromRGBO(215, 117, 255, 1).withOpacity(0.8),
              Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, 1],
          )),
        ),
        SingleChildScrollView(
          child: Container(
            height: deviceSize.height,
            width: deviceSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 94),
                    transform: Matrix4.rotationZ(-8 * pi / 180)
                      ..translate(-10.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ]),
                    child: Text(
                      'My Shop',
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: Colors.white,
                          fontSize: 50,
                          fontFamily: 'Anton'),
                    ),
                  ),
                ),
                Flexible(
                  flex: deviceSize.width > 600 ? 2 : 1,
                  child: AuthCard(),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key?key}) : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();
}

enum AuthMode { Login, SignUp }

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  AuthMode authMode = AuthMode.Login;

  Map<String, String> _authData = {'email': '', 'password': ''};

  var _isLoading = false;
  final passwordController = TextEditingController();

  late AnimationController controller;
  late Animation<Offset> slideAnimation;
  late Animation<double> opacityAnimation;

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    slideAnimation = Tween<Offset>(begin: Offset(0, -0.15), end: Offset(0, 0))
        .animate(
            CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn));

    opacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('An error occured'),
              content: Text(message),
              actions: [
                TextButton(
                  child: Text('Okay!'),
                  onPressed: () => Navigator.of(ctx).pop(),
                )
              ],
            ));
  }

  _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).login(_authData['email']!, _authData['password']!);
      } else {
        await Provider.of<Auth>(context, listen: false)
            .signUp(_authData['email']!, _authData['password']!);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid Password';
      }
      _showErrorDialog(errorMessage.toString());
    } catch (error) {
      const errorMessage = 'Could not authenticate you.Please try again later';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (authMode == AuthMode.Login) {
      setState(() {
        authMode = AuthMode.SignUp;
      });
      controller.forward();
    } else {
      setState(() {
        authMode = AuthMode.Login;
      });
      controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: authMode == AuthMode.SignUp ? 320.0 : 260.0,
        width: deviceSize.width * 0.85,
        constraints:
            BoxConstraints(minHeight: authMode == AuthMode.SignUp ? 330 : 270),
        padding: EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(label: Text('Email')),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val!.isEmpty || !val.contains('a')) {
                      return 'Invalid Email';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _authData['email'] = val!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(label: Text('Password')),
                  obscureText: true,
                  controller: passwordController,
                  validator: (val) {
                    if (val!.isEmpty || val.length <= 5) {
                      return 'Password is too short';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _authData['password'] = val!;
                  },
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: authMode == AuthMode.SignUp ? 60 : 0,
                    maxHeight: authMode == AuthMode.SignUp ? 160 : 0,
                  ),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: opacityAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: TextFormField(
                        enabled: authMode == AuthMode.SignUp,
                        decoration:
                            InputDecoration(label: Text('Confirm Password')),
                        obscureText: true,
                        validator: authMode == AuthMode.SignUp
                            ? (val) {
                                if (val != passwordController.text) {
                                  return "Password doesn't match";
                                }
                                return null;
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (_isLoading) CircularProgressIndicator(),
                ElevatedButton(
                  child: Text(authMode == AuthMode.Login ? 'Login' : 'SignUp'),
                  onPressed: _submit,
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      )),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 30, vertical: 4)),
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.primary),
                      foregroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryTextTheme.headline6!.color)),
                ),
                TextButton(
                  child: Text(
                      '${authMode == AuthMode.Login ? 'SignUp' : 'Login'} Instead'),
                  onPressed: _switchAuthMode,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primary),
                    foregroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryTextTheme.headline6!.color),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
