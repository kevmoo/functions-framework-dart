// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';
import 'dart:io';

import 'package:functions_framework/functions_framework.dart';
import 'package:functions_framework/src/cloud_metadata.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';

String? _projectId;
http.Client? _client;

@CloudFunction()
Future<Response> function(Request request) async {
  if (_projectId == null) {
    final metadata = CloudMetadata();
    try {
      final result = await metadata.projectInfo();
      _projectId = result.projectId;
    } on SocketException catch (e) {
      print('Could not access metadata server.');
      print(e);
      print('Trying local GCLOUD_PROJECT variable instead!');
      _projectId = Platform.environment['GCLOUD_PROJECT'];
    } finally {
      metadata.close();
    }
  }

  if (_projectId == null) {
    throw UnsupportedError('Not sure why we do not have a project id!');
  }

  _client ??= await createClient();

  final content = await incrementCore(_client!, _projectId!);

  return Response.ok(
    JsonUtf8Encoder(' ').convert(content),
    headers: {
      'content-type': 'application/json',
    },
  );
}

Future<http.Client> createClient() => clientViaApplicationDefaultCredentials(
      scopes: [
        '"https://www.googleapis.com/auth/datastore"',
      ],
    );

Future<Object> incrementCore(http.Client client, String projectId) async {
  final api = FirestoreApi(client);

  final fieldTx = FieldTransform()
    ..fieldPath = 'count'
    ..increment = (Value()..integerValue = '1');

  final docTx = DocumentTransform()
    ..document =
        'projects/$projectId/databases/(default)/documents/settings/count'
    ..fieldTransforms = [fieldTx];

  final request = CommitRequest()
    ..writes = [
      Write()..transform = docTx,
    ];

  final theList = await api.projects.databases.documents.commit(
    request,
    'projects/$projectId/databases/(default)',
  );

  return theList;
}
