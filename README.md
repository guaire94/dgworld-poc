# dgworld_poc

## Before Start

1. You can use Postman to easily simulate API Call and test the app -> https://www.getpostman.com/collections/9410268d5f06ad953fdb (the needed collection)
2. You can find the Postman environement in postman directory -> DGWorld POC.postman_environment.json
3. The Postman collection contains two directory:
    - Send by Talabat, what we plain to send to DGWorld POS
    - Send by DGWorld, what we plain to retrieve from DGWorld POS

## Requirement

1. Install Flutter https://flutter.dev/docs/get-started/install
2. SetUp Editor https://flutter.dev/docs/get-started/editor (prefer Android Studio)
3. Use latest version stable of Flutter
4. Fetch needed dependencies, Go to pubspec.yaml, click Pub get
5. Run project
6. Prefer using iOS simulator to run the app, local network works well without any changes

Notive: If you wanna use Android simulator, the config will be different to reach it
An article to help configure and make it work on Android https://futurestud.io/tutorials/how-to-run-an-android-app-against-a-localhost-api

## Config

You can edit in the config.dart file (lib/utils/config.dart:
    - APIConfig (Send by Talabat)
        - server host
        - server port
        - Pay route
        - request body
    - ServerConfig (Send by DGWorld)
        - server host
        - server port
        - Payment route

