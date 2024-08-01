# Zone 2 Training

## Overview

Ensure you are training in your Zone 2 heart rate using a Heart Rate Monitor and a cycling trainer with ERG mode.

## How I created the images and icon packs:
Use Icon Kitchen to create the icon design. [Icon Kitchen](https://icon.kitchen/i/H4sIAAAAAAAAAz1Qy27EIAz8F%2Feay7ZqpebaH6jUv∑VVVZWJD0DoxAtLuapV%2FX5N9cDBmGA8znOEPZeEC%2FRkI82E%2F8sTQe5TCHfjwITFhru26sG1A7HGRCh3EQWcDEhPKr4sHhnWbUNFs%2BJPflhFd2J%2BSiULISJHnNuyQAj%2Boz7v3N%2F9isL9Th9u7DfpEojiH5qFqgn732kGOYTQ7rXVaq07XXthvqDlx4WvEq1bMg7BJ1RaOHunMFx%2Frko1jyvcWSo0pGX81kUlpkfY734AzZY3Ugmux%2Bs%2FO6oSDnX7WCyv99axIAQAA)
Then use App Icon to create the mac icon if necessary. [App Icon](https://www.appicon.co/)
Feature image created here [Hotpot AI](https://hotpot.ai)

## Publishing App

### Android App
Login to developer console and open project. [Console](https://play.google.com/console)
Ensure setup for signing and build of app bundle has been performed [Deployment docs](https://docs.flutter.dev/deployment/android)
Update version in pubspec.yaml. For example, 1.0.5+5 would become 1.0.6+6 (VER_NAME+VER_CODE).
Run `flutter build appbundle` to build app bundle
App bundle can be found at ./build/app/outputs/bundle/release/app.aab
Upload bundle to play console [docs](https://developer.android.com/studio/publish/upload-bundle)
