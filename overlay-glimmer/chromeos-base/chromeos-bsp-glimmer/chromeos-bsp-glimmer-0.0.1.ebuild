# Copyright 2013 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit appid cros-audio-configs

DESCRIPTION="Glimmer private bsp (meta package to pull in driver/tool deps)"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="-* amd64 x86"
IUSE="glimmer-cheets"

RDEPEND="
	chromeos-base/chromeos-touch-config-glimmer
"

# Previously existed?
#chromeos-base/chromeos-accelerometer-init

DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_install() {
	if use glimmer-cheets; then
		doappid "{107B04CD-3BF8-9C1F-6838-4AD43AE8EC1A}" "CHROMEBOOK"
	else
		doappid "{D0DBB0D9-6EEB-B148-F8AF-AE8AF86ECE5B}" "CHROMEBOOK" # glimmer
	fi

	# Install platform specific config files for power_manager.
	insinto "/usr/share/power_manager/board_specific"
	doins "${FILESDIR}"/powerd_prefs/*

	# Install audio config files.
	local audio_config_dir="${FILESDIR}/audio-config"
	install_audio_configs swanky "${audio_config_dir}"
}
