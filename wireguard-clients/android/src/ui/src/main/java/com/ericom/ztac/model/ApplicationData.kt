/*
 * Copyright © 2017-2019 WireGuard LLC. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */
/* keep the name in future upgrades */


package com.ericom.ztac.model

import android.graphics.drawable.Drawable
import androidx.databinding.BaseObservable
import androidx.databinding.Bindable
import com.ericom.ztac.BR
import com.ericom.ztac.databinding.Keyed

class ApplicationData(val icon: Drawable, val name: String, val packageName: String, isSelected: Boolean) : BaseObservable(), Keyed<String> {
    override val key = name

    @get:Bindable
    var isSelected = isSelected
        set(value) {
            field = value
            notifyPropertyChanged(BR.selected)
        }
}
