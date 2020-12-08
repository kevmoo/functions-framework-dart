// Copyright 2020 Google LLC
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

import 'dart:async';

import 'package:shelf/shelf.dart';

import 'src/wip.dart';

/// 1) Annotations should not be needed. Can just inspect the shape of the
/// function. Annotations are only needed to override the name
/// 2) Should likely use the name of the function to specify the target.
/// so this `function` is mapped to "function" target.
Response function(Request request) => Response.ok('ok');

/// 3) Allow functions to have the same target – as long as they have different
/// methods
/// 4) If we're filtering on method, then send a HTTP 405 and do the right thing
// Explicit – although should maybe use an enum here
@CloudFunction(target: 'function', method: HttpMethod.delete)
// Or give folks easy constructors here
@CloudFunction.delete(target: 'function')
FutureOr<Response> deleteMe(Request request) => Response(100);

// TODO: we *could* allow the same Dart function to handle multiple different
// targets and methods – not too hard to implement, but adds a bit of complexity
// to discuss

/// 5) We see this and we know to wire up this function to target `cloudEvent`
/// 6) If the incoming HTTP request doesn't map to the expected shape of a
/// cloudEvent we send a 400 (or 500?)
/// 7) Otherwise, we instantiate a [CloudEvent] instance and pass it in.
/// 8) The return type is `void` to discourage the user from returning anything
/// 9) Need to come up with known exceptions the user can use to send specific
/// status codes other than 200.
/// [CloudEvent] implements/extends [CloudEventContext] but adds the data field
FutureOr<void> cloudEvent(CloudEvent event) => null;

/// 10) Do we want to offer implementors optional access to the underlying
/// [Request] or maybe just the headers? Or either/both?
FutureOr<void> cloudEventMore(
  CloudEvent event, {
  Request request,
  Map<String, String> headers,
  Map<String, List<String>> headers2,
}) =>
    null;

/// 11) If you create a function that matches a known type, we just wire up all
/// of the logic.
///
/// So this is the cloudEvent case ++. We validate the input is a CloudEvent
/// **AND** making sure the event "type" matches and that we can decode the
/// [CloudEvent] content into the matching `PubSubTopicSubscription`
/// [PubSubTopicSubscription] must implement/extend [CloudEventContext]
FutureOr<void> handlePubSub(PubSubTopicSubscription subscription) => null;

/// 12) Turns out the out-of-the-box event types **are not special**!
/// They just follow the right pattern of implementing/extending the right
/// base class plus having the right configuration (likely an annotation on
/// the class like [CloudEventType]. We can "do the right thing" for types that
/// have a content type of JSON.
FutureOr<void> handleMyEvent(MyCustomEvent event) => null;

@CloudEventType('com.example.custom')
class MyCustomEvent extends CloudEventContext {
  MyCustomEvent() : super('com.example.custom');

  // ignore: avoid_unused_constructor_parameters
  factory MyCustomEvent.fromJson(Map<String, dynamic> json) => null;

  Map<String, dynamic> toJson() => null;
}
