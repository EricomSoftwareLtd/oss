/* SPDX-License-Identifier: MIT
 *
 * Copyright (C) 2019-2020 WireGuard LLC. All Rights Reserved.
 */

package updater

const (
	releasePublicKeyBase64 = "RWRNqGKtBXftKTKPpBPGDMe8jHLnFQ0EdRy8Wg0apV6vTDFLAODD83G4"
	updateServerHost       = "my.download.site"
	updateServerPort       = 443
	updateServerUseHttps   = true
	latestVersionPath      = "/windows-client/latest.sig"
	msiPath                = "/windows-client/%s"
	msiArchPrefix          = "ZTEdge-%s-"
	msiSuffix              = ".msi"
)
