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

import 'package:functions_framework/functions_framework.dart';
import 'package:functions_framework/src/cloud_metadata.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:shelf/shelf.dart';

String projectId;

@CloudFunction()
Future<Response> function(Request request) async {
  if (projectId == null) {
    final metadata = CloudMetadata();
    try {
      final result = await metadata.projectInfo();
      projectId = result.projectId;
    } finally {
      metadata.close();
    }
  }

  if (projectId == null) {
    throw UnsupportedError('Not sure why we do not have a project id!');
  }

  final client = await clientViaApplicationDefaultCredentials(
    scopes: [
      '"https://www.googleapis.com/auth/datastore"',
    ],
  );

  try {
    final api = FirestoreApi(client);
    final theList = await api.projects.locations.list('projects/$projectId');

    return Response.ok(
      const JsonEncoder.withIndent(' ').convert(theList),
      headers: {
        'content-type': 'application/json',
      },
    );
  } finally {
    client.close();
  }
}
