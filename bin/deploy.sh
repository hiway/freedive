#!/bin/sh -eu

LATEST_PKG_FILE="$( cd pkg && ls -tr *.pkg | tail -n 1 )"
LATEST_PKG_PATH="pkg/${LATEST_PKG_FILE:?}"

REMOTE_SERVER="wok"
REMOTE_PKG_PATH="deploy/freedive/${LATEST_PKG_FILE:?}"

echo "Uploading ${LATEST_PKG_FILE} ==> ${REMOTE_SERVER}"
scp "${LATEST_PKG_PATH:?}" "${REMOTE_SERVER:?}:${REMOTE_PKG_PATH:?}"

echo "Stopping service if already runing"
ssh wok -- doas service freedive stop || echo "Service not running?"

echo "Installing package"
ssh wok -- doas pkg install -y "${REMOTE_PKG_PATH}"

echo "Starting service"
ssh wok -- doas service freedive start
