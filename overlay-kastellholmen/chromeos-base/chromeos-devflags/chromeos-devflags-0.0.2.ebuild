# Copyright 2012 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

#inherit  cros-workon cros-unibuild platform cros-protobuf  user
#inherit   cros-unibuild platform cros-protobuf  user

DESCRIPTION="Hack for /etc(chrome)"
HOMEPAGE="https://example.com"
#SRC_URI=""
S="${WORKDIR}"

SLOT="0"
LICENSE="BSD-Google"
KEYWORDS="*"
IUSE=""




src_install() {
	
	insinto /etc
	#touch chrome_dev.conf
	doins "${FILESDIR}"/chrome_dev.conf

}
