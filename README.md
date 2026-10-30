# kasi-bites-track1

WTC-97PCAL7L

A mobile ordering platform designed to connect township food vendors (Kasi food spots) with local customers. Built as part of the Mobile Development Curriculum (Track 1: Flutter &amp; Dart).
Kasi Bites Merchant Mobile Application

(Complete project)
Kasi Bites is a cross-platform mobile application built with Flutter and Dart. It is designed for township food vendors to track, manage, and process customer orders in real time. The app features a live merchant dashboard, asynchronous REST API synchronization with a backend server, Twilio webhook integration for customer orders, and push notification alerts powered by Firebase Cloud Messaging.

Core Features

Live Order Dashboard: Automatically polls and displays active customer orders separated by workflow states including pending, preparing, and completed.

Twilio WhatsApp Integration: Ingests incoming customer orders placed via WhatsApp through Twilio webhooks, parsing form data and queueing orders instantly.

Status Management: Allows merchants to update order statuses instantly with a single tap, which immediately triggers a REST update back to the server.

Push Notifications: Registers device tokens securely on application startup and listens for background and foreground message hooks to alert merchants of incoming orders.

Cross-Platform Support: Built from a single codebase targeting mobile environments.

Tech Stack

Framework: Flutter SDK

Language: Dart

Messaging & Webhooks: Twilio WhatsApp API

Cloud Services: Firebase Cloud Messaging

Networking: HTTP package for REST communication and JSON parsing

Project Structure

kasi-bites-track1/
│
├── android/
│   ├── app/
│   │   ├── src/
│   │   │   ├── main/
│   │   │   │   ├── java/za/co/wethinkcode/kasi_bites/
│   │   │   │   │   └── MainActivity.kt
│   │   │   │   ├── AndroidManifest.xml
│   │   │   │   └── res/
│   │   │   └── debug/
│   │   ├── build.gradle
│   │   └── build.gradle.kts
│   ├── build.gradle
│   ├── gradle.properties
│   └── settings.gradle
│
├── ios/
│   ├── Runner/
│   │   ├── AppDelegate.swift
│   │   ├── Base.lproj/
│   │   └── Info.plist
│   └── Runner.xcodeproj/
│
├── lib/
│   ├── models/
│   │   └── order.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   └── fcm_service.dart
│   ├── screens/
│   │   ├── dashboard_screen.dart
│   │   └── order_details_screen.dart
│   └── main.dart
│
├── test/
│   └── widget_test.dart
│
├── build/
│   └── app/outputs/flutter-apk/
│       └── app-debug.apk
│
├── .gitignore
├── analysis_options.yaml
├── pubspec.yaml
└── README.md


Prerequisites

Flutter SDK installed on your machine

Android Studio or Android SDK tools with an active virtual device configured

Java Development Kit for running the local backend companion server

Twilio account configured with WhatsApp Sandbox enabled

Setup and Running Instructions

Navigate to the project directory:

cd kasi-bites-track1



Install dependencies:

flutter pub get



Ensure the local backend server is running on port 8082. The mobile app uses the Android emulator loopback address (http://10.0.2.2:8082) to communicate with the local machine.

Configure your Twilio Sandbox webhook URL to point to your backend endpoint (/webhook/whatsapp) using a tunneling service if testing incoming WhatsApp orders live.

Execution Commands

Launch the Android Emulator

flutter emulators --launch Medium_Phone_API_37.0

npx localtunnel --port 8082

Run the Application in Debug Mode

flutter run

docker run -d -p 8082:8082 kasi-bites-dashboard:latest


Useful Terminal Shortcuts During Execution

r: Hot reload for rapid UI updates

R: Hot restart to reset app state and re-run initialization

q: Terminate the application session

Build a Debug APK

flutter clean
flutter pub get
flutter build apk --debug



The compiled output will be located at build/app/outputs/flutter-apk/app-debug.apk.

API Integration Endpoints

The system integrates across the following backend and webhook routes:

POST /webhook/whatsapp: Ingests incoming form data payloads from Twilio when customers send WhatsApp messages

GET /api/orders: Retrieves the active list of customer orders for the merchant dashboard

PUT /api/orders/{id}/status: Updates the workflow state for a specific order

POST /api/devices: Registers the device FCM token for push notifications