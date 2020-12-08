import 'package:meta/meta_meta.dart';

class CloudEventContext {
  final String type;
  Object id, source, specVersion, time, subject, dataSchema, dataContentType;

  CloudEventContext(this.type);
}

class CloudEvent extends CloudEventContext {
  Object data;

  CloudEvent(String type) : super(type);
}

enum HttpMethod { delete }

@Target({TargetKind.function})
class CloudFunction {
  final String target;
  final HttpMethod method;

  const CloudFunction({this.target = 'function', this.method});

  const CloudFunction.delete({this.target = 'function'})
      : method = HttpMethod.delete;
}

@CloudEventType('google.cloud.pubsub.topic.publish')
class PubSubTopicSubscription {}

@Target({TargetKind.classType})
class CloudEventType {
  final String type;

  const CloudEventType(this.type);
}
