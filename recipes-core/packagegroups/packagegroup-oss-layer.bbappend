OSS_FEED_SOURCE = "${DEPLOY_DIR_IPK}/${OSS_LAYER_ARCH}"
OSS_FEED_DEST ?= "${HOME}/ipk/rdk-oss-release/4.6.2-community/${MACHINE}/ipks"

# Wait until all dependency packages have been written and checked.
do_publish_oss_feed[recrdeptask] += "do_package_write_ipk do_package_qa"
do_publish_oss_feed[depends] += "opkg-utils-native:do_populate_sysroot rsync-native:do_populate_sysroot"

# Publish on every invocation, including builds satisfied from shared state.
do_publish_oss_feed[nostamp] = "1"

do_publish_oss_feed() {
    # pipefail prevents publishing if indexing or compression fails.
    bash -o pipefail -c 'opkg-make-index "$1/" | gzip -c9 > "$1/Packages.gz"' _ "${OSS_FEED_SOURCE}"

    install -d "${OSS_FEED_DEST}"
    rsync -av "${OSS_FEED_SOURCE}/" "${OSS_FEED_DEST}/"
}

addtask publish_oss_feed after do_package_write_ipk before do_build
