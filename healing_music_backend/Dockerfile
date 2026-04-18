# Stage 1: Build
FROM dart:stable AS builder

WORKDIR /app

# Copy dependency manifests first for better layer caching
COPY pubspec.yaml ./

# Install dependencies
RUN dart pub get

# Copy the rest of the source code
COPY . .

# Install Dart Frog CLI and build the production bundle
RUN dart pub global activate dart_frog_cli
RUN dart pub global run dart_frog_cli:dart_frog build

# Stage 2: Run
FROM dart:stable

WORKDIR /app

# Copy the compiled build output from the builder stage
COPY --from=builder /app/build .

# Pre-compile the entry point for faster cold starts
RUN dart compile exe main.dart -o server

EXPOSE 8080

CMD ["./server"]
