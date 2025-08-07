import 'package:base_architecture/src/shared/constants/color_constants.dart';
import 'package:base_architecture/src/shared/constants/image_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/router/route_const.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _navigateAfterDelay();

  }

  void _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.goNamed(RouteConst.start);
    }
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'v${info.version} (${info.buildNumber})';
    });
  }

  void _onPressStart() {
    context.goNamed(RouteConst.loginPage);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      ImageConst.splashName,
                      height: 210,
                      fit: BoxFit.fitHeight,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'ClearVisit',
                      style: TextStyle(
                        fontSize: 60,
                        color: ColorConst.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'Understand every\nconversation',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 25, color: ColorConst.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                width: 330,
                child: ElevatedButton(
                    onPressed: _onPressStart,child: Text("Get Started",style: TextStyle(color: ColorConst.white,fontWeight: FontWeight.w800,fontSize: 16),)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


}
