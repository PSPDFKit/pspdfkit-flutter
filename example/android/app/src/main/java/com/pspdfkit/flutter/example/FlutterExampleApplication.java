package com.pspdfkit.flutter.example;

import android.content.Context;

import androidx.multidex.MultiDex;
import io.flutter.app.FlutterApplication;

public class FlutterExampleApplication extends FlutterApplication {
    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }
}
