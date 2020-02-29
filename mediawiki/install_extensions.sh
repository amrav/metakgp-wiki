#!/usr/bin/env bash

set -xe

declare -a extension_names=( \
    AbuseFilter \
    ArticleFeedbackv5 \
    CheckUser \
    CommonsMetadata \
    ContributionScores \
    Echo \
    MobileFrontend \
    SandboxLink \
    StopForumSpam \
    VisualEditor \
    WikimediaMessages \
    googleAnalytics \
)

declare -A extension_version_overrides=( \
    # remove once we upgrade to mediawiki 1.34
    ["ArticleFeedbackv5"]="master" \
)

declare -a skin_names=( \
    MinervaNeue \
)

MEDIAWIKI_RELEASE=REL1_34

function fetch_extension_url() {
    curl -s "https://www.mediawiki.org/wiki/Special:ExtensionDistributor?extdistname=$1&extdistversion=$2" \
        | grep -oP 'https://extdist.wmflabs.org/dist/extensions/.*?.tar.gz' \
        | head -1
}

function fetch_skin_url() {
    curl -s "https://www.mediawiki.org/wiki/Special:SkinDistributor?extdistname=$1&extdistversion=$2" \
        | grep -oP 'https://extdist.wmflabs.org/dist/skins/.*?.tar.gz' \
        | head -1
}

cd /tmp
for extension_name in "${extension_names[@]}"; do
    version=$MEDIAWIKI_RELEASE
    if [[ -v "extension_version_overrides[$extension_name]" ]]; then
	version=${extension_version_overrides[$extension_name]}
    fi
    versioned_extension_url=$(fetch_extension_url $extension_name $version)
    versioned_extension_name=$(echo $versioned_extension_url | awk -F"/" '{print $(NF)}')
    wget -q $versioned_extension_url
    tar -xzf "$versioned_extension_name"
    mv $extension_name /srv/mediawiki/extensions/
done

for skin_name in "${skin_names[@]}"; do
    versioned_skin_url=$(fetch_skin_url $skin_name $MEDIAWIKI_RELEASE)
    versioned_skin_name=$(echo $versioned_skin_url | awk -F"/" '{print $(NF)}')
    wget -q $versioned_skin_url
    tar -xzf "$versioned_skin_name"
    mv $skin_name /srv/mediawiki/skins/
done

# Get RecentPages from Github
wget -q https://github.com/leucosticte/RecentPages/archive/master.zip \
    && unzip master.zip -d RecentPages \
    && mv RecentPages/RecentPages-master /srv/mediawiki/extensions/RecentPages

# Make Lua executable
chmod a+x /srv/mediawiki/extensions/Scribunto/includes/engines/LuaStandalone/binaries/lua5_1_5_linux_64_generic/lua

# Download StopForumSpam blacklist
wget -q https://www.stopforumspam.com/downloads/listed_ip_30_ipv46.zip \
    && unzip listed_ip_30_ipv46.zip -d listed_ip_30_ipv46 \
    && mv listed_ip_30_ipv46 /srv/mediawiki/extensions/StopForumSpam/
