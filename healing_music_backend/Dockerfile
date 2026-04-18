FROM dart:stable

WORKDIR /app

# Install dart_frog_cli
RUN dart pub global activate dart_frog_cli

COPY pubspec.* ./
RUN dart pub get

COPY . .

# Build production server
RUN dart pub global run dart_frog_cli:dart_frog build

EXPOSE 8080

CMD ["dart", "build/bin/server.dart"]