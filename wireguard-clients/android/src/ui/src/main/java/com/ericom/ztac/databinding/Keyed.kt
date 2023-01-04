/*
 * Copyright © 2020 WireGuard LLC. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */
/* keep the name in future upgrades */


package com.ericom.ztac.databinding

/**
 * Interface for objects that have a identifying key of the given type.
 */
interface Keyed<K> {
    val key: K
}
