/*
 * Copyright © 2021 WireGuard LLC. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

package com.ericom.ztac.activation;

public class ActivatonManager {

    private static native String wgGetConfig(int handle);

}
