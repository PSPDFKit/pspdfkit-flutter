# PSPDFKit Flutter

PSPDFKit wrapper for Flutter.

> If you are new to Flutter, make sure to check our [introductory blog post "How I Got Started With Flutter"](https://pspdfkit.com/blog/2018/starting-with-flutter/)

Platform specific READMEs exist for [Android](android/) and [iOS](ios/).

# Setup

## Integration into existing Flutter apps

TBD 

## Integration into a new Flutter app

TBD

# Example

To see PSPDFKit Flutter in action check out our [Flutter example app](example/).

Showing a PDF document inside you Flutter app is as simple as this:

```MyApp.dart 
openExternalDocument() async {
    try {
        Pspdfkit.openExternalDocument("document.pdf");
    } on PlatformException catch (e) {
        print("Failed to open document: '${e.message}'.");
    }
}
```

# Troubleshooting

TBD

# Contributing

TBD