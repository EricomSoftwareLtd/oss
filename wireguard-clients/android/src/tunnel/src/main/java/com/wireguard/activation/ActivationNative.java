/*
 * Copyright © 2021 WireGuard LLC. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

package com.wireguard.activation;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;

import com.wireguard.android.util.SharedLibraryLoader;
import com.wireguard.util.NonNullForAll;

@NonNullForAll
public final class ActivationNative {
    private final Context context;

    /**
     *     enum APIError: Int32 {
     *         case noError = 0
     *         case noActivationNeeded = 2
     *         case webActivationRequired = 3
     *         case noInternet = -1
     *         case httpError = -2
     *         case serverError = -3
     *         case invalidCredentials = -4
     */

    public enum ECodes {
        NO_ERROR(/*number*/0, ""),
        INVALID_CREDENTIALS(-4, "Invalid credentials"),
        SERVER_ERROR(-3, "Server error"),
        GENERIC_ERROR(-1, "Generic error");

        private final int id;
        private final String message;

        ECodes(final int id, final String message) {
            this.id = id;
            this.message = message;
        }

        public int getId() { return id; }
        public String getMessage() { return message; }
    }

    public ActivationNative(final Context context) {
        SharedLibraryLoader.loadSharedLibrary(context, "MFA");
        this.context = context;
    }

    private native String activate(String host, String key);
    private native int verifyActivationResult(String host, String url);

    public int OpenBrowser(String url) {

        if (!url.startsWith("http://") && !url.startsWith("https://"))
            url = "http://" + url;

        final Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        browserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(browserIntent);

        return 0;
    }


    public String GetActivationURL(final String host, final String key) {
       return activate(host, key);
    }

    public int VerifyActivationResult(final String host, final String url) {
        return verifyActivationResult(host, url);
    }

}