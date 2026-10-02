#!/bin/bash

pushd $RK_PROJECT_PACKAGE_ROOTFS_DIR

replace_same_file_as_symlink() {
	local src_file="$1"
	local dest_file="$2"

	# check if src_file exists
	if [ ! -f "$src_file" ]; then
		echo "Source file $src_file does not exist."
		return
	fi

	# check if dst_file exists and is a symlink
	if [ -L "$dest_file" ]; then
		local link_target=$(readlink "$dest_file")
		if [ "$link_target" == "$src_file" ]; then
			echo "Symlink $dest_file already points to $src_file."
			return
		fi
	fi
	
	# calculate sha256 checksum of src_file
	local src_sha256=$(sha256sum "$src_file" | awk '{print $1}')
	local dest_sha256=$(sha256sum "$dest_file" | awk '{print $1}')

	# check if src_file and dest_file are the same
	if [ "$src_sha256" != "$dest_sha256" ]; then
		echo "Source file $src_file and destination file $dest_file are different."
		return
	fi

	# remove the destination file if it exists
	if [ -f "$dest_file" ]; then
		rm -f "$dest_file"
	fi

	# create a symlink to the source file
	ln -s "$src_file" "$dest_file"
	echo "Created symlink $dest_file -> $src_file"
}

echo "+ Deduplicating the libraries"

pushd $RK_PROJECT_PACKAGE_OEM_DIR/usr/lib/

# TODO: automate this process
# replace_same_file_as_symlink libnftables.so.1.1.0 libnftables.so.1
# replace_same_file_as_symlink libnftables.so.1 libnftables.so

# replace_same_file_as_symlink libmnl.so.0.2.0 libmnl.so.0
# replace_same_file_as_symlink libmnl.so.0 libmnl.so

popd

echo "+ Removing unused files"

rm -v $RK_PROJECT_PACKAGE_ROOTFS_DIR/oem/usr/lib/*.data

echo "+ Removing GDB"

rm -v $RK_PROJECT_PACKAGE_ROOTFS_DIR/bin/gdb
rm -v $RK_PROJECT_PACKAGE_ROOTFS_DIR/bin/gdbserver

echo "+ Removing RKAIQ related files"

rm -v $RK_PROJECT_PACKAGE_ROOTFS_DIR/oem/usr/bin/rkaiq_*
rm -v $RK_PROJECT_PACKAGE_ROOTFS_DIR/oem/usr/bin/j2s4b_dev
rm -rfv $RK_PROJECT_PACKAGE_ROOTFS_DIR/etc/iqfiles/*

echo "+ Removing demo files"
rm -rfv $RK_PROJECT_PACKAGE_ROOTFS_DIR/oem/usr/bin/rkisp_demo

echo "+ Installing USB network helpers"
install -D -m 0755 \
	$SDK_ROOT_DIR/project/app/wifi_app/precompile/$RK_TOOLCHAIN_CROSS/bin/dnsmasq \
	$RK_PROJECT_PACKAGE_ROOTFS_DIR/usr/bin/dnsmasq
# The vendor dnsmasq links gettext, which in turn links libiconv. These
# libraries are removed from the minimal rootfs unless installed explicitly.
install -D -m 0755 \
	$SDK_ROOT_DIR/project/app/wifi_app/precompile/$RK_TOOLCHAIN_CROSS/lib/libintl.so.8.1.6 \
	$RK_PROJECT_PACKAGE_ROOTFS_DIR/usr/lib/libintl.so.8.1.6
ln -sf libintl.so.8.1.6 $RK_PROJECT_PACKAGE_ROOTFS_DIR/usr/lib/libintl.so.8
install -D -m 0755 \
	$SDK_ROOT_DIR/project/app/component/third_libs/lib/$RK_TOOLCHAIN_CROSS/libiconv.so.2.6.1 \
	$RK_PROJECT_PACKAGE_ROOTFS_DIR/usr/lib/libiconv.so.2.6.1
ln -sf libiconv.so.2.6.1 $RK_PROJECT_PACKAGE_ROOTFS_DIR/usr/lib/libiconv.so.2
