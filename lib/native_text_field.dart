// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class NativeTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String text;
  final TextStyle textStyle;
  final String placeHolder;
  final TextStyle placeHolderStyle;
  final int maxLength;
  final TextAlign textAlign;
  final double width;
  final VoidCallback onEditingComplete;
  final Function(String) onSubmitted;
  final Function(String) onChanged;
  final bool autoFocus;

  const NativeTextField({
    this.controller,
    this.focusNode,
    this.text = '',
    this.textStyle,
    this.placeHolder = '',
    this.placeHolderStyle,
    this.maxLength = 5000,
    this.textAlign = TextAlign.start,
    this.width,
    this.onEditingComplete,
    this.onSubmitted,
    this.onChanged,
    this.autoFocus = false,
  });

  @override
  _NativeTextFieldState createState() => _NativeTextFieldState();
}

class _NativeTextFieldState extends State<NativeTextField> {

  MethodChannel _channel;
  TextEditingController _controller;
  FocusNode _focusNode;

  Map createParams() {
    return {
      'width': widget.width ?? MediaQuery.of(context).size.width,
      'text': widget.text,
      'textStyle': {
        'color': widget.textStyle.color.value,
        'fontSize': widget.textStyle.fontSize,
        'height': widget.textStyle.height ?? 1.17
      },
      'placeHolder': widget.placeHolder,
      'placeHolderStyle': {
        'color': widget.placeHolderStyle.color.value,
        'fontSize': widget.placeHolderStyle.fontSize,
        'height': widget.placeHolderStyle.height ?? 1.35
      },
      'textAlign': widget.textAlign.toString(),
      'maxLength': widget.maxLength,
      'done': widget.onEditingComplete != null || widget.onSubmitted != null
    };
  }

  @override
  void initState() {
    if (widget.autoFocus)
      Future.delayed(const Duration(milliseconds: 300)).then((_) {
        _channel?.invokeMethod('updateFocus', true);
      });

    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    _controller.addListener(() {
      _channel.invokeMethod('setText', _controller.text);
    });
    super.initState();
  }

  Future<void> _handlerCall(MethodCall call) async {
    switch (call.method) {
      case 'updateFocus':
        final focus = call.arguments ?? false;
        if (focus) {
          _focusNode.requestFocus();
        } else {
          _focusNode.unfocus();
        }
        break;
      case 'updateText':
        print('updateText: ${call.arguments ?? ''}');
        _controller.text = call.arguments ?? '';
        break;
      case 'submitText':
        final text = call.arguments ?? '';
        widget.onSubmitted?.call(text);
        widget.onEditingComplete?.call();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return SizedBox(
        height: 44,
        child: Focus(
          focusNode: _focusNode,
          onFocusChange: (focus) {
            _channel.invokeMethod('updateFocus', focus);
          },
          child: UiKitView(
            viewType: "com.fanbook.native_textfield",
            creationParams: createParams(),
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: (viewId) {
              _channel = MethodChannel('com.fanbook.native_textfield_$viewId');
              _channel.setMethodCallHandler(_handlerCall);
            },
          ),
        ),
      );
    }
    return Text('暂不支持该平台');
  }
}
