/*
 * Copyright 2024 Hongen Wang All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:network_proxy/network/util/cert/x509.dart';

///证书哈希名称查看
///@author Hongen Wang
class CertHashPage extends StatefulWidget {
  const CertHashPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CertHashPageState();
  }
}

class _CertHashPageState extends State<CertHashPage> {
  var input = TextEditingController();
  TextEditingController decodeData = TextEditingController();

  AppLocalizations get localizations => AppLocalizations.of(context)!;

  @override
  void dispose() {
    input.dispose();
    decodeData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title:  Text(localizations.systemCertName, style: TextStyle(fontSize: 16)), centerTitle: true),
        resizeToAvoidBottomInset: false,
        body: ListView(children: [
          Wrap(alignment: WrapAlignment.end, children: [
            ElevatedButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(type: FileType.custom, allowedExtensions: ['crt', 'pem', 'cer']);
                  if (result == null) return;
                  File file = File(result.files.single.path!);
                  String content = await file.readAsString();
                  input.text = content;
                  getSubjectName();
                },
                style: buttonStyle,
                icon: const Icon(Icons.folder_open),
                label: Text("File")),
            const SizedBox(width: 15),
            ElevatedButton.icon(
                onPressed: () => input.clear(),
                style: buttonStyle,
                icon: const Icon(Icons.clear),
                label: const Text("Clear")),
            const SizedBox(width: 15),
            FilledButton.icon(
                onPressed: () {
                  getSubjectName();
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                style: buttonStyle,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text("Run")),
            const SizedBox(width: 15),
          ]),
          const SizedBox(width: 10),
          Container(
              padding: const EdgeInsets.all(10),
              height: 350,
              child: TextFormField(
                  maxLines: 50,
                  controller: input,
                  onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                  keyboardType: TextInputType.text,
                  decoration: decoration(localizations.inputContent))),
          Align(
              alignment: Alignment.bottomLeft,
              child: TextButton(onPressed: () {}, child: const Text("Output:", style: TextStyle(fontSize: 16)))),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              height: 150,
              child: TextFormField(
                  maxLines: 30,
                  readOnly: true,
                  controller: decodeData,
                  decoration: decoration('Android ${localizations.systemCertName}'))),
        ]));
  }

  getSubjectName() {
    var content = input.text;
    if (content.isEmpty) return;
    try {
      var caCert = X509Utils.x509CertificateFromPem(content);

      var subject = caCert.tbsCertificate?.subject;
      if (subject == null) return;
      var subjectHashName = X509Generate.getSubjectHashName(subject);
      decodeData.text = '$subjectHashName.0';
    } catch (e) {
      FlutterToastr.show(localizations.decodeFail, context, duration: 3, backgroundColor: Colors.red);
    }
  }

  ButtonStyle get buttonStyle =>
      ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(horizontal: 15, vertical: 8)),
          textStyle: MaterialStateProperty.all<TextStyle>(const TextStyle(fontSize: 14)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));

  InputDecoration decoration(String label, {String? hintText}) {
    Color color = Theme
        .of(context)
        .colorScheme
        .primary;
    return InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: label,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        border: OutlineInputBorder(borderSide: BorderSide(width: 0.8, color: color)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 1.5, color: color)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: color)));
  }
}
