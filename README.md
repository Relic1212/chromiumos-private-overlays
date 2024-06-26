This directory contains board and variant overlays.  When a board is
configured using `setup_board --board <board>` the following overlays are added
to the `make.conf` `PORTDIR_OVERLAY` if they exist:

```
src/overlays/overlay-<board>
src/private-overlays/overlay-<board>-private
```

When a board is configured using `setup_board --board <board> --variant
<variant>` or `setup_board --board <board>_<variant>` the following overlays
are added if they exist:

```
src/overlays/overlay-<board>
src/overlays/overlay-variant-<board>-<variant>
src/private-overlays/overlay-<board>-private
src/private-overlays/overlay-variant-<board>-<variant>-private
```

If `--variant` is supplied to setup_board or the `<board>_<variant>` version
of `--board` is supplied to setup_board then the primary variant overlay must
exist.

A private board overlay can augment an existing non-private board overlay,
or can serve as the primary board overlay for a board with no non-private board
overlay.

All board overlays (including variants) should contain a `make.conf`.  If
this file exists it will be sourced in the order that the overlays and variants
are listed above.

All board overlays should contain a `toolchain.conf`, specifying the
toolchains required to build that board.  Variants can inherit `toolchain.conf`
from their primary board overlay.

The board and variant names can not have underscores or spaces in them.


## Profiles

All overlays must contain a profiles directory with a `repo_name` file
therein.  The `repo_name` file provides a unique name Portage uses to identify
each overlay or variant.

Overlays and variants can also contain named profiles as subdirectories of
the profiles directory.  If the board overlay contains a `base` profile,
Portage will use that by default for the board; otherwise, Portage will use a
profile from chromiumos-overlay.

Within a profile, a board overlay will most commonly want to specify
package-specific USE flags via package.use, mask or unmask package versions via
package.mask and package.unmask, or mask or unmask keywords via
package.keywords.  See `man portage` in the chroot for full details on those
and other files that can appear in a profile.

Profiles in a board overlay must have a file `parent`, containing the full
path of one of the profiles from chromiumos-overlay, as seen from the build
chroot; `/usr/local/portage/chromiumos/profiles` in the chroot maps to
`src/third_party/chromiumos-overlay/profiles` in the source tree.  The parent
must point to an architecture-appropriate profile, typically
`/usr/local/portage/chromiumos/profiles/default/linux/$arch/$version/chromeos`.
Profiles can use another profile from the same board as their parent, as long
as the chain of parent profiles eventually leads to an architecture-appropriate
profile from chromiumos-overlay.

Adding a base profile to a board overlay that did not previously have a
profile will require re-running setup_board with `--force`.


## `layout.conf`

Overlays should contain a metadata directory with a `layout.conf` file
therein.  The `layout.conf` file specifies the `masters` list.  This is a list of
repository names, taken from the `repo_name` files in the overlays.  This list
disambiguates the selection of ebuilds.  When two overlays supply the same
ebuild the overlay whose `repo_name` is listed later in the masters list will be
used.  The masters list also effects the way that portage searches for
eclasses.  By having the `repo_name` `chromiumos` as the last entry in the
masters list portage will correctly find the chromiumos specific eclasses.


## Board-specific packages

A board overlay will typically want to provide additional packages to
install.  ChromiumOS builds install the `chromeos/chromeos` package by default,
whose RDEPEND brings in all the packages installed by default.
`chromeos/chromeos` RDEPENDs on the virtual package `virtual/chromeos-bsp`, which
exists for board overlays to override.  chromiumos-overlay provides a default
version of `virtual/chromeos-bsp` which RDEPENDs on the empty package
`chromeos-base/chromeos-bsp-null`.  Board overlays should provide a
`virtual/chromeos-bsp` package that RDEPENDs on
`chromeos-base/chromeos-bsp-boardname`, and a
`chromeos-base/chromeos-bsp-boardname` package that RDEPENDs on any desired
board-specific packages.

A board overlay can also provide additional packages to install in dev
builds only, via similar packages `virtual/chromeos-bsp-dev` and
`chromeos-base/chromeos-bsp-dev-boardname`.  ChromiumOS dev builds install
`chromeos-base/chromeos-dev` by default, which RDEPENDs on
`virtual/chromeos-bsp-dev`.

Note that a board overlay cannot specify package-specific USE flags by
using an RDEPEND with a use flag, such as section/package[useflag]; instead,
add "section/package useflag" to package.use in a profile.


## Private host overlays

The host (non-cross-compiling) build environment will use the following
overlay if it exists:

```
src/private-overlays/chromeos-overlay
```

This overlay contains private packages needed on the host system to compile
target packages used in a private overlay.  Packages only needed on the target
system should appear in a private board overlay.  The packages in a private
host overlay should typically all appear in the dependency chain of
`chromeos-base/hard-host-depends` so that the build process will install them on
the host system at the appropriate time.  `chromeos-base/hard-host-depends`
depends on the virtual package `virtual/hard-host-depends-bsp` to allow a private
host overlay to extend the host dependencies; a private host overlay can
provide a version 2 ebuild for `virtual/hard-host-depends-bsp`, and list any
additional host dependencies in the RDEPEND of that package.

Like a board overlay, a private host overlay must include a `layout.conf`
with `masters` set, so that the packages within that host overlay can reference
eclasses from the parent overlays chromiumos-overlay or portage-stable.
