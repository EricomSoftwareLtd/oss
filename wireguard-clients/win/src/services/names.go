/* SPDX-License-Identifier: MIT
 *
 * Copyright (C) 2019 WireGuard LLC. All Rights Reserved.
 */

package services

import (
	"errors"

	"golang.zx2c4.com/wireguard/windows/conf"
)

func ServiceNameOfTunnel(tunnelName string) (string, error) {
	if !conf.TunnelNameIsValid(tunnelName) {
		return "", errors.New("Tunnel name is not valid")
	}
	return "ZteTunnel$" + tunnelName, nil
}

func PipePathOfTunnel(tunnelName string) (string, error) {
	if !conf.TunnelNameIsValid(tunnelName) {
		return "", errors.New("Tunnel name is not valid")
	}
	return `\\.\pipe\ProtectedPrefix\Administrators\ZTE\` + tunnelName, nil
}
