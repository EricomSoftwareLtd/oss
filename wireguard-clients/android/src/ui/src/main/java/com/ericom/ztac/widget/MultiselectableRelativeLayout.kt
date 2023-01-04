/*
 * Copyright © 2017-2019 WireGuard LLC. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */
/* keep the name in future upgrades */

package com.ericom.ztac.widget

import android.content.Context
import android.util.AttributeSet
import android.view.View
import android.widget.RelativeLayout
import com.ericom.ztac.R

class MultiselectableRelativeLayout @JvmOverloads constructor(
        context: Context? = null,
        attrs: AttributeSet? = null,
        defStyleAttr: Int = 0,
        defStyleRes: Int = 0
) : RelativeLayout(context, attrs, defStyleAttr, defStyleRes) {
    private var multiselected = false

    override fun onCreateDrawableState(extraSpace: Int): IntArray {
        if (multiselected) {
            val drawableState = super.onCreateDrawableState(extraSpace + 1)
            View.mergeDrawableStates(drawableState, STATE_MULTISELECTED)
            return drawableState
        }
        return super.onCreateDrawableState(extraSpace)
    }

    fun setMultiSelected(on: Boolean) {
        if (!multiselected) {
            multiselected = true
            refreshDrawableState()
        }
        isActivated = on
    }

    fun setSingleSelected(on: Boolean) {
        if (multiselected) {
            multiselected = false
            refreshDrawableState()
        }
        isActivated = on
    }

    companion object {
        private val STATE_MULTISELECTED = intArrayOf(R.attr.state_multiselected)
    }
}
