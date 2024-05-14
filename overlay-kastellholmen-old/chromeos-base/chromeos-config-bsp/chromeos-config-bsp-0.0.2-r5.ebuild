# Copyright 2021 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

# cros_workon applies only to ebuild and files directory. Use the
# canonical empty project.
CROS_WORKON_COMMIT="d2d95e8af89939f893b1443135497c1f5572aebc"
CROS_WORKON_TREE="776139a53bc86333de8672a51ed7879e75909ac9"
CROS_WORKON_PROJECT="chromiumos/infra/build/empty-project"
CROS_WORKON_LOCALNAME="platform/empty-project"

inherit cros-workon cros-unibuild appid

DESCRIPTION="ChromeOS model configuration"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/chromeos-config/README.md"

LICENSE="BSD-Google"
KEYWORDS="*"
RDEPEND="
	chromeos-base/chromeos-devflags
	sys-firmware/fwupd-uefi-dbx
	chromeos-base/reven-hwdb
	chromeos-base/reven-quirks
"
# TODO
#	chromeos-base/flex_hwis
#	chromeos-base/reven-hwdb
#	chromeos-base/reven-quirks

src_install() {
	install_model_files
	doappid "{C924E0C4-AF80-4B6B-A6F0-DD75EDBCC37C}" "CHROMEBOOK"

}
