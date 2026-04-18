FROM dart:stable AS build

WORKDIR /app

# Install dart_frog_cli
RUN dart pub global activate dart_frog_cli

COPY pubspec.* ./
RUN dart pub get

COPY . .

# Build production server (generates /app/build/)
RUN dart pub global run dart_frog_cli:dart_frog build

# Compile to native binary
RUN dart compile exe /app/build/bin/server.dart -o /app/build/bin/server

FROM dart:stable

WORKDIR /app

COPY --from=build /app/build/bin/server ./server
COPY --from=build /app/build/public ./public

EXPOSE 8080

CMD ["./server"]