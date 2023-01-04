/*
 * Copyright © 2017-2019 WireGuard LLC. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */
/* keep the name in future upgrades */

package com.ericom.ztac.model

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import android.widget.Toast
import androidx.databinding.BaseObservable
import androidx.databinding.Bindable
import com.ericom.ztac.Application.Companion.get
import com.ericom.ztac.Application.Companion.getBackend
import com.ericom.ztac.Application.Companion.getTunnelManager
import com.ericom.ztac.BR
import com.ericom.ztac.R
import com.ericom.ztac.configStore.ConfigStore
import com.ericom.ztac.databinding.ObservableSortedKeyedArrayList
import com.ericom.ztac.util.ErrorMessages
import com.ericom.ztac.util.UserKnobs
import com.ericom.ztac.util.applicationScope
import com.wireguard.activation.ActivationNative
import com.wireguard.android.backend.Statistics
import com.wireguard.android.backend.Tunnel
import com.wireguard.config.ActivationData
import com.wireguard.config.Config
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Maintains and mediates changes to the set of available WireGuard tunnels,
 */
class TunnelManager(private val configStore: ConfigStore) : BaseObservable() {
    private val tunnels = CompletableDeferred<ObservableSortedKeyedArrayList<String, ObservableTunnel>>()
    private val context: Context = get()
    private val tunnelMap: ObservableSortedKeyedArrayList<String, ObservableTunnel> = ObservableSortedKeyedArrayList(TunnelComparator)
    private var haveLoaded = false
    private var activationNative = ActivationNative(get())

    private fun addToList(name: String, config: Config?, state: Tunnel.State): ObservableTunnel {
        val tunnel = ObservableTunnel(this, name, config, state)
        tunnelMap.add(tunnel)
        return tunnel
    }

    suspend fun getTunnels(): ObservableSortedKeyedArrayList<String, ObservableTunnel> = tunnels.await()

    suspend fun create(name: String, config: Config?): ObservableTunnel = withContext(Dispatchers.Main.immediate) {
        if (Tunnel.isNameInvalid(name))
            throw IllegalArgumentException(context.getString(R.string.tunnel_error_invalid_name))
        if (tunnelMap.containsKey(name))
            throw IllegalArgumentException(context.getString(R.string.tunnel_error_already_exists, name))
        addToList(name, withContext(Dispatchers.IO) { configStore.create(name, config!!) }, Tunnel.State.DOWN)
    }

    suspend fun delete(tunnel: ObservableTunnel) = withContext(Dispatchers.Main.immediate) {
        val originalState = tunnel.state
        val wasLastUsed = tunnel == lastUsedTunnel
        // Make sure nothing touches the tunnel.
        if (wasLastUsed)
            lastUsedTunnel = null
        tunnelMap.remove(tunnel)
        try {
            if (originalState == Tunnel.State.UP)
                withContext(Dispatchers.IO) { getBackend().setState(tunnel, Tunnel.State.DOWN, null) }
            try {
                withContext(Dispatchers.IO) { configStore.delete(tunnel.name) }
            } catch (e: Throwable) {
                if (originalState == Tunnel.State.UP)
                    withContext(Dispatchers.IO) { getBackend().setState(tunnel, Tunnel.State.UP, tunnel.config) }
                throw e
            }
        } catch (e: Throwable) {
            // Failure, put the tunnel back.
            tunnelMap.add(tunnel)
            if (wasLastUsed)
                lastUsedTunnel = tunnel
            throw e
        }
    }

    @get:Bindable
    var lastUsedTunnel: ObservableTunnel? = null
        private set(value) {
            if (value == field) return
            field = value
            notifyPropertyChanged(BR.lastUsedTunnel)
            applicationScope.launch { UserKnobs.setLastUsedTunnel(value?.name) }
        }

    suspend fun getTunnelConfig(tunnel: ObservableTunnel): Config = withContext(Dispatchers.Main.immediate) {
        tunnel.onConfigChanged(withContext(Dispatchers.IO) { configStore.load(tunnel.name) })!!
    }

    fun onCreate() {
        applicationScope.launch {
            try {
                onTunnelsLoaded(withContext(Dispatchers.IO) { configStore.enumerate() }, withContext(Dispatchers.IO) { getBackend().runningTunnelNames })
            } catch (e: Throwable) {
                Log.e(TAG, Log.getStackTraceString(e))
            }
        }
    }

    private fun onTunnelsLoaded(present: Iterable<String>, running: Collection<String>) {
        for (name in present)
            addToList(name, null, if (running.contains(name)) Tunnel.State.UP else Tunnel.State.DOWN)
        applicationScope.launch {
            val lastUsedName = UserKnobs.lastUsedTunnel.first()
            if (lastUsedName != null)
                lastUsedTunnel = tunnelMap[lastUsedName]
            haveLoaded = true
            restoreState(true)
            tunnels.complete(tunnelMap)
        }
    }

    private fun refreshTunnelStates() {
        applicationScope.launch {
            try {
                val running = withContext(Dispatchers.IO) { getBackend().runningTunnelNames }
                for (tunnel in tunnelMap)
                    tunnel.onStateChanged(if (running.contains(tunnel.name)) Tunnel.State.UP else Tunnel.State.DOWN)
            } catch (e: Throwable) {
                Log.e(TAG, Log.getStackTraceString(e))
            }
        }
    }

    suspend fun restoreState(force: Boolean) {
        if (!haveLoaded || (!force && !UserKnobs.restoreOnBoot.first()))
            return

        val activatingTunnel = UserKnobs.activatingTunnel.first()
        if(activatingTunnel?.isNotEmpty() == true) {
            return
        }
        val previouslyRunning = UserKnobs.runningTunnels.first()
        if (previouslyRunning.isEmpty()) return
        withContext(Dispatchers.IO) {
            try {
                tunnelMap.filter { previouslyRunning.contains(it.name) }.map { async(Dispatchers.IO + SupervisorJob()) { setTunnelState(it, Tunnel.State.UP) } }.awaitAll()
            } catch (e: Throwable) {
                Log.e(TAG, Log.getStackTraceString(e))
            }
        }
    }

    suspend fun saveState() {
        UserKnobs.setRunningTunnels(tunnelMap.filter { it.state == Tunnel.State.UP }.map { it.name }.toSet())
    }

    suspend fun setTunnelConfig(tunnel: ObservableTunnel, config: Config): Config = withContext(Dispatchers.Main.immediate) {
        tunnel.onConfigChanged(withContext(Dispatchers.IO) {
            getBackend().setState(tunnel, tunnel.state, config)
            configStore.save(tunnel.name, config)
        })!!
    }

    suspend fun setTunnelName(tunnel: ObservableTunnel, name: String): String = withContext(Dispatchers.Main.immediate) {
        if (Tunnel.isNameInvalid(name))
            throw IllegalArgumentException(context.getString(R.string.tunnel_error_invalid_name))
        if (tunnelMap.containsKey(name)) {
            throw IllegalArgumentException(context.getString(R.string.tunnel_error_already_exists, name))
        }
        val originalState = tunnel.state
        val wasLastUsed = tunnel == lastUsedTunnel
        // Make sure nothing touches the tunnel.
        if (wasLastUsed)
            lastUsedTunnel = null
        tunnelMap.remove(tunnel)
        var throwable: Throwable? = null
        var newName: String? = null
        try {
            if (originalState == Tunnel.State.UP)
                withContext(Dispatchers.IO) { getBackend().setState(tunnel, Tunnel.State.DOWN, null) }
            withContext(Dispatchers.IO) { configStore.rename(tunnel.name, name) }
            newName = tunnel.onNameChanged(name)
            if (originalState == Tunnel.State.UP)
                withContext(Dispatchers.IO) { getBackend().setState(tunnel, Tunnel.State.UP, tunnel.config) }
        } catch (e: Throwable) {
            throwable = e
            // On failure, we don't know what state the tunnel might be in. Fix that.
            getTunnelState(tunnel)
        }
        // Add the tunnel back to the manager, under whatever name it thinks it has.
        tunnelMap.add(tunnel)
        if (wasLastUsed)
            lastUsedTunnel = tunnel
        if (throwable != null)
            throw throwable
        newName!!
    }

    suspend fun finishActivation(data: String, onSuccess: (message: String) -> Unit, onError: (message: String) -> Unit) = withContext(Dispatchers.IO) {
        val activatingTunnel = UserKnobs.activatingTunnel.first()
        if(activatingTunnel?.isNotEmpty() == false) {
            return@withContext
        }
        withContext(Dispatchers.IO) {
            try {
                tunnelMap.filter { activatingTunnel!!.contains(it.name) }.map { tunnel ->
                    async(Dispatchers.IO + SupervisorJob()) {

                        val host = tunnel.config?.activationData?.host.toString()
                        val key = tunnel.config?.activationData?.publicKey?.toBase64()
                        if(host.isEmpty() || key.isNullOrEmpty()){
                            return@async
                        }

                        when(activationNative.VerifyActivationResult(host,  data)) {
                            ActivationNative.ECodes.NO_ERROR.id -> {
                                UserKnobs.setActivatingTunnel(null)
                                setTunnelState(tunnel, Tunnel.State.UP)
                                onSuccess("")
                            }
                            ActivationNative.ECodes.INVALID_CREDENTIALS.id -> onError(ActivationNative.ECodes.INVALID_CREDENTIALS.message)
                            ActivationNative.ECodes.SERVER_ERROR.id -> onError(ActivationNative.ECodes.SERVER_ERROR.message)
                            else -> onError(ActivationNative.ECodes.GENERIC_ERROR.message)
                        }
                    }
                }.awaitAll()
            } catch (e: Throwable) {
                Log.e(TAG, Log.getStackTraceString(e))
            }
        }
    }

    suspend fun activateTunnel(tunnel: ObservableTunnel, activationData: ActivationData) = withContext(Dispatchers.IO) {
        UserKnobs.setActivatingTunnel(tunnel.name)
        val url = activationNative.GetActivationURL(activationData.host.toString(), activationData.publicKey.toBase64())
        if ("" == url ) {
            getTunnelManager().setTunnelState(tunnel, Tunnel.State.UP)
        } else {
            // reset toggle switch to be able to use it or another tunnel after user cancellation
            getTunnelManager().setTunnelState(tunnel, Tunnel.State.DOWN)
            activationNative.OpenBrowser(url)
        }
    }


    suspend fun setTunnelState(tunnel: ObservableTunnel, state: Tunnel.State): Tunnel.State =
        withContext(Dispatchers.Main.immediate) {
            var newState = tunnel.state
            var throwable: Throwable? = null
            try {
                newState = withContext(Dispatchers.IO) {
                    getBackend().setState(
                        tunnel,
                        state,
                        tunnel.getConfigAsync()
                    )
                }
                if (newState == Tunnel.State.UP)
                    lastUsedTunnel = tunnel
            } catch (e: Throwable) {
                throwable = e
            }
            tunnel.onStateChanged(newState)
            saveState()
            if (throwable != null)
                throw throwable
            newState
        }


    class IntentReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent?) {
            applicationScope.launch {
                val manager = getTunnelManager()
                if (intent == null) return@launch
                val action = intent.action ?: return@launch
                if ("com.ericom.ztac.action.REFRESH_TUNNEL_STATES" == action) {
                    manager.refreshTunnelStates()
                    return@launch
                }
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || !UserKnobs.allowRemoteControlIntents.first())
                    return@launch
                val state: Tunnel.State
                state = when (action) {
                    "com.ericom.ztac.action.SET_TUNNEL_UP" -> Tunnel.State.UP
                    "com.ericom.ztac.action.SET_TUNNEL_DOWN" -> Tunnel.State.DOWN
                    else -> return@launch
                }
                val tunnelName = intent.getStringExtra("tunnel") ?: return@launch
                val tunnels = manager.getTunnels()
                val tunnel = tunnels[tunnelName] ?: return@launch
                try {
                    manager.setTunnelState(tunnel, state)
                } catch (e: Throwable) {
                    Toast.makeText(context, ErrorMessages[e], Toast.LENGTH_LONG).show()
                }
            }
        }
    }

    suspend fun getTunnelState(tunnel: ObservableTunnel): Tunnel.State = withContext(Dispatchers.Main.immediate) {
        tunnel.onStateChanged(withContext(Dispatchers.IO) { getBackend().getState(tunnel) })
    }

    suspend fun getTunnelStatistics(tunnel: ObservableTunnel): Statistics = withContext(Dispatchers.Main.immediate) {
        tunnel.onStatisticsChanged(withContext(Dispatchers.IO) { getBackend().getStatistics(tunnel) })!!
    }

    companion object {
        private const val TAG = "WireGuard/TunnelManager"
    }
}
