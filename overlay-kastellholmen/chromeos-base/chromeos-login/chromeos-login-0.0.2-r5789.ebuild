# Copyright 2012 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="7228ae192fa3fc93f34d3ad656e32f4458e616b3"
CROS_WORKON_TREE=("874585cec1956489988d3d144fab5b49e3b1aaf8" "26e131fe56975cf86ec923b130f50e8d1bd465ac" "dd06490dae2504baa92f74398419464a71bdee9c" "0e2e8468d1a663b7af9ead8a1c7fe0f85ff15016" "083569b82e5bcbfefd8700a2cd52ea619e712f7a" "29c9e10e65bb9e93fd1a0634a794addfa7e82b1c" "22713d4b26f3d0e94389c1b09daffdf4a19b7521" "d87a5ef6d075a6ba047883ce105cc7903d02a01a" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(b/187784160): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk chromeos-config libcontainer libcrossystem libpasswordprovider login_manager libsegmentation metrics .gn"

PLATFORM_SUBDIR="login_manager"

# Do not run test parallelly until unit tests are fixed.
# shellcheck disable=SC2034
PLATFORM_PARALLEL_GTEST_TEST="no"

inherit tmpfiles cros-workon cros-unibuild platform cros-protobuf systemd user

DESCRIPTION="Login manager for Chromium OS."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/login_manager/"
SRC_URI=""

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="apply_landlock_policy arc_adb_sideloading cheets flex_id fuzzer
	+apply_landlock_policy +login_apply_no_new_privs login_enable_crosh_sudo systemd test
	user_session_isolation"

COMMON_DEPEND="chromeos-base/bootstat:=
	chromeos-base/chromeos-config-tools:=
	chromeos-base/minijail:=
	chromeos-base/cryptohome:=
	chromeos-base/libchromeos-ui:=
	chromeos-base/libcontainer:=
	chromeos-base/libcrossystem:=
	chromeos-base/libpasswordprovider:=
	chromeos-base/libsegmentation:=
	>=chromeos-base/metrics-0.0.1-r3152:=
	chromeos-base/vpd:=
	dev-libs/nspr:=
	dev-libs/nss:=
	fuzzer? ( dev-libs/libprotobuf-mutator:= )
	sys-apps/dbus:=
	sys-apps/util-linux:=
"

RDEPEND="${COMMON_DEPEND}
	acct-group/session_manager
	acct-user/session_manager
	flex_id? ( chromeos-base/flex_id:= )
"

DEPEND="${COMMON_DEPEND}
	>=chromeos-base/protofiles-0.0.43:=
	chromeos-base/system_api:=[fuzzer?]
	chromeos-base/vboot_reference:=
	test? (
		dev-util/shunit2
		sys-process/procps
		sys-process/lsof
	)
"

BDEPEND="
	app-crypt/nss
	chromeos-base/chromeos-dbus-bindings
"
PATCHES=(
	"${FILESDIR}/001-no-devflags.patch"
)
pkg_preinst() {
	enewgroup policy-readers
}

platform_pkg_test() {
	local tests=( session_manager_test )

	# Qemu doesn't support signalfd currently, and it's not clear how
	# feasible it is to implement :(.
	# So, filter out the tests that rely on signalfd().
	local gtest_qemu_filter=""
	if ! use x86 && ! use amd64; then
		gtest_qemu_filter+="-ChildExitHandlerTest.*"
		gtest_qemu_filter+=":SessionManagerProcessTest.*"
	fi

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}" "0" "" "${gtest_qemu_filter}"
	done

	if use x86 || use amd64; then
		platform_test "run" "./init/scripts/ui-killers-helper_unittest"
	fi
}

src_install() {
	platform_src_install

	# Adding init scripts.
	if use systemd; then
		systemd_dounit init/systemd/*
		systemd_enable_service x-started.target
		systemd_enable_service multi-user.target ui.target
		systemd_enable_service ui.target ui.service
		systemd_enable_service ui.service machine-info.service
		systemd_enable_service login-prompt-visible.target send-uptime-metrics.service
		systemd_enable_service login-prompt-visible.target ui-init-late.service
		systemd_enable_service start-user-session.target login.service
		systemd_enable_service system-services.target ui-collect-machine-info.service
	fi

	dotmpfiles tmpfiles.d/chromeos-login.conf

	# For user session processes.
	dodir /etc/skel/log

	# For user NSS database
	diropts -m0700
	# Need to dodir each directory in order to get the opts right.
	dodir /etc/skel/.pki
	dodir /etc/skel/.pki/nssdb
	# Yes, the created (empty) DB does work on ARM, x86 and x86_64.
	certutil -N -d "sql:${D}/etc/skel/.pki/nssdb" -f <(echo '') || die

	# Create daemon store directories.
	local daemon_store="/etc/daemon-store/session_manager"
	dodir "${daemon_store}"
	fperms 0700 "${daemon_store}"
	fowners root:root "${daemon_store}"

	local fuzzers=(
		login_manager_validator_utils_fuzzer
		login_manager_validator_utils_policy_desc_fuzzer
	)

	local fuzzer
	for fuzzer in "${fuzzers[@]}"; do
		# fuzzer_component_id is unknown/unlisted
		platform_fuzzer_install "${S}"/OWNERS "${OUT}/${fuzzer}"
	done
}
