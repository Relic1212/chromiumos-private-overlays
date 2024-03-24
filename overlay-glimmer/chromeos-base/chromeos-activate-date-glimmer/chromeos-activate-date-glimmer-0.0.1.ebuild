# Copyright 2014 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Chrome OS activate date mechanism"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

RDEPEND="chromeos-base/ec-utils"

S=${WORKDIR}

src_install() {
	dosbin "${FILESDIR}/activate_date"

	insinto "/etc/init"
	doins "${FILESDIR}/activate_date.conf"
}
