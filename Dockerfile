################
FROM google/dart:2.12

# cache deps
WORKDIR /app
COPY ./functions_framework/pubspec.yaml /app/functions_framework/
COPY ./functions_framework_builder/pubspec.yaml /app/functions_framework_builder/
COPY ./examples/firebase_api_example/pubspec.yaml /app/examples/firebase_api_example/

WORKDIR /app/examples/firebase_api_example
RUN dart pub get

# As long as pubspecs haven't changed, all deps should be cached and only
# new image layers from here on need to get rebuild for modified sources.
COPY . ../..
RUN dart pub get --offline

RUN dart pub run build_runner build --delete-conflicting-outputs
RUN dart compile exe bin/server.dart -o bin/server

########################
FROM subfuzion/dart:slim
COPY --from=0 /app/examples/firebase_api_example/bin/server /app/bin/server
EXPOSE 8080
ENTRYPOINT ["/app/bin/server"]
