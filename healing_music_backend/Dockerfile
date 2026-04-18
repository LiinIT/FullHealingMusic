FROM dart:stable AS build

WORKDIR /app

# Install dart_frog_cli
RUN dart pub global activate dart_frog_cli

COPY pubspec.* ./
RUN dart pub get

COPY . .

# Build production server
RUN dart pub global run dart_frog_cli:dart_frog build

FROM dart:stable

WORKDIR /app

COPY --from=build /app/build/bin/server .
COPY --from=build /app/build/public ./public

EXPOSE 8080

CMD ["./server"]