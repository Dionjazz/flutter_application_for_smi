import 'dart:js_interop';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;

import 'package:web/web.dart' as web;

/// Entrypoint of the application.
void main() => runApp(MyApp());

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: const HomePage());
  }
}

/// [Widget] displaying the home page consisting of an image the the buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  web.HTMLImageElement? _imageElement;

  /// Whether the menu is currently displayed to the user.
  bool _showMenu = false;

  /// Creating an [web.HTMLDivElement]
  void registerRedDivFactory() {
    ui_web.platformViewRegistry.registerViewFactory(
      'image-container',
      (int id, {Object? params}) {
        final web.HTMLDivElement myDiv = web.HTMLDivElement()
          ..id = 'image-container'
          ..style.backgroundColor = 'white'
          ..style.overflow = 'hidden'
          ..style.width = '100%'
          ..style.height = '100%';

        return myDiv;
      },
    );
  }

  /// Image update validation.
  /// Stops if imput isEmpty, if not replacing [container] children.
  void _updateImage() {
    final rawUrl = _urlController.text.trim();
    if (rawUrl.isEmpty) return;

    final web.Element? container =
        web.document.getElementById('image-container');
    if (container != null) {
      container.replaceChildren(''.toJS);
      _loadImage(rawUrl, container);
    }
  }

  /// Actual update of [container] with image from [url]
  void _loadImage(String url, web.Element container) {
    _imageElement = web.HTMLImageElement()
      ..id = 'image'
      ..src = url
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..onDoubleClick
          .listen((_) => _handleFullScreen(!web.document.fullscreen));

    container.append(_imageElement!);
  }

  /// Toggle fullscreen using JavaScript interop.
  /// Checks fullscreen is enabled & depends on that if [isFull] not passed.
  void _handleFullScreen(bool? isFull) {
    if (web.document.fullscreen && isFull != true) {
      web.document.exitFullscreen();
    } else if (isFull != false) {
      web.document.documentElement?.requestFullscreen();
    }
  }

  @override
  void initState() {
    super.initState();
    // Register a container for the HTML image.
    registerRedDivFactory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: HtmlElementView(viewType: 'image-container'),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        autofocus: true,
                        decoration: InputDecoration(hintText: 'Image URL'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _updateImage(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                        child: Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
          if (_showMenu)
            GestureDetector(
              onTap: () => setState(() => _showMenu = false),
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.black54,
              ),
            ),
          if (_showMenu)
            Positioned(
              right: 16,
              bottom: 80,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  children: [
                    CupertinoButton(
                      onPressed: () => _handleFullScreen(true),
                      child: const Text('Enter fullscreen'),
                    ),
                    CupertinoButton(
                      onPressed: () => _handleFullScreen(false),
                      child: const Text('Exit fullscreen'),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showMenu = true),
        child: Icon(Icons.add),
      ),
    );
  }
}
