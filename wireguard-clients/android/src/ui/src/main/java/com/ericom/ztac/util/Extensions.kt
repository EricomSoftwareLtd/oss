/*
 * Copyright © 2020 WireGuard LLC. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */
/* keep the name in future upgrades */
package com.ericom.ztac.util

import android.content.Context
import android.util.TypedValue
import androidx.annotation.AttrRes
import androidx.lifecycle.lifecycleScope
import androidx.preference.Preference
import com.ericom.ztac.Application
import com.ericom.ztac.activity.SettingsActivity
import kotlinx.coroutines.CoroutineScope

fun Context.resolveAttribute(@AttrRes attrRes: Int): Int {
    val typedValue = TypedValue()
    theme.resolveAttribute(attrRes, typedValue, true)
    return typedValue.data
}

val Any.applicationScope: CoroutineScope
    get() = Application.getCoroutineScope()

val Preference.activity: SettingsActivity
    get() = context as? SettingsActivity
            ?: throw IllegalStateException("Failed to resolve SettingsActivity")

val Preference.lifecycleScope: CoroutineScope
    get() = activity.lifecycleScope
