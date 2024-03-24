# Copyright 2014 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit appid cros-audio-configs

DESCRIPTION="Rambi private bsp (meta package to pull in driver/tool deps)"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="-* amd64 x86"
IUSE=""
S="${WORKDIR}"

RDEPEND="
	!<chromeos-base/chromeos-bsp-rambi-private-0.0.1-r2
	chromeos-base/chromeos-touch-config-rambi
"
DEPEND="${RDEPEND}"

src_install() {
	doappid "{22235CFE-C5A2-414E-688D-239AC44675DB}" "CHROMEBOOK"

	# Install platform specific config files for power_manager.
	insinto "/usr/share/power_manager/board_specific"
	doins "${FILESDIR}"/powerd_prefs/*

	# Install audio config files.
	local audio_config_dir="${FILESDIR}/audio-config"
	install_audio_configs swanky "${audio_config_dir}"
}
