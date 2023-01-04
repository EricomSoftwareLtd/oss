/*
 * Copyright © 2017-2019 WireGuard LLC. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */
/* keep the name in future upgrades */


package com.ericom.ztac.activity

import android.os.Bundle
import androidx.fragment.app.commit
import com.ericom.ztac.fragment.TunnelEditorFragment
import com.ericom.ztac.model.ObservableTunnel

/**
 * Standalone activity for creating tunnels.
 */
class TunnelCreatorActivity : BaseActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (supportFragmentManager.findFragmentById(android.R.id.content) == null) {
            supportFragmentManager.commit {
                add(android.R.id.content, TunnelEditorFragment())
            }
        }
    }

    override fun onSelectedTunnelChanged(oldTunnel: ObservableTunnel?, newTunnel: ObservableTunnel?) {
        finish()
    }
}
