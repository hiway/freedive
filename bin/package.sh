#!/bin/sh -eu

APP_NAME="$( grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g' )"
APP_VERSION="$( grep 'version:' mix.exs | cut -d '"' -f2 )"

mix phx.digest.clean --all

mix deps.get --only prod

export MIX_ENV=prod

mix compile
mix assets.deploy
mix release --overwrite

mix phx.digest.clean --all

PKG_NAME="$APP_NAME-$APP_VERSION.pkg"
PROJECT_DIR="$( pwd )"
BUILD_DIR="${PROJECT_DIR}/_build/prod/rel"
TEMPLATE_DIR="${PROJECT_DIR}/bin/templates"
STAGE_DIR="$( mktemp -d -t "${APP_NAME}-${APP_VERSION}" )"
ARCHIVE_DIR="${PROJECT_DIR}/pkg/"

cp "${TEMPLATE_DIR}/stage/+MANIFEST" "${STAGE_DIR}/+MANIFEST"
sed -i '' -e "s/APP_VERSION/${APP_VERSION}/g" "${STAGE_DIR}/+MANIFEST"
sed -i '' -e "s/APP_NAME/${APP_NAME}/g" "${STAGE_DIR}/+MANIFEST"

cp "${TEMPLATE_DIR}/stage/+POST_INSTALL" "${STAGE_DIR}/+POST_INSTALL"
sed -i '' -e "s/APP_VERSION/${APP_VERSION}/g" "${STAGE_DIR}/+POST_INSTALL"
sed -i '' -e "s/APP_NAME/${APP_NAME}/g" "${STAGE_DIR}/+POST_INSTALL"
chmod +x "${STAGE_DIR}/+POST_INSTALL"

cp "${TEMPLATE_DIR}/stage/+PRE_DEINSTALL" "${STAGE_DIR}/+PRE_DEINSTALL"
sed -i '' -e "s/APP_VERSION/${APP_VERSION}/g" "${STAGE_DIR}/+PRE_DEINSTALL"
sed -i '' -e "s/APP_NAME/${APP_NAME}/g" "${STAGE_DIR}/+PRE_DEINSTALL"
chmod +x "${STAGE_DIR}/+PRE_DEINSTALL"

mkdir -p "${STAGE_DIR}/usr/local/etc/rc.d"
cp "${TEMPLATE_DIR}/etc/rc.d/${APP_NAME}" "${STAGE_DIR}/usr/local/etc/rc.d/${APP_NAME}"
chmod +x "${STAGE_DIR}/usr/local/etc/rc.d/${APP_NAME}"

mkdir -p "${STAGE_DIR}/usr/local/${APP_NAME}/scripts/"
cp "${TEMPLATE_DIR}"/${APP_NAME}/scripts/*.sh "${STAGE_DIR}/usr/local/${APP_NAME}/scripts/"
chmod +x "${STAGE_DIR}"/usr/local/${APP_NAME}/scripts/*

mkdir -p "${STAGE_DIR}/usr/local/${APP_NAME}"
cp -a "${BUILD_DIR}/${APP_NAME}" "${STAGE_DIR}/usr/local/"

SECRET_KEY_BASE="$( openssl rand -hex 32 | tr -d '\n' )"

mkdir -p "${STAGE_DIR}/usr/local/etc"
cp "${APP_NAME}.toml.sample" "${STAGE_DIR}/usr/local/etc/${APP_NAME}.toml.sample"
sed -i '' -e "s/CHANGE-ME/${SECRET_KEY_BASE}/g" "${STAGE_DIR}/usr/local/etc/${APP_NAME}.toml.sample"
sed -i '' -e "s/DATA-PATH-PREFIX/\/var\/db\/freedive/g" "${STAGE_DIR}/usr/local/etc/${APP_NAME}.toml.sample"


cd "${STAGE_DIR}" || exit 1
find "usr" -type f -ls| awk '{print "/" $NF}' >> "${STAGE_DIR}/plist"

cd "${PROJECT_DIR}" || exit 1
mkdir -p "${ARCHIVE_DIR}"

pkg create -m "${STAGE_DIR}/" -r "${STAGE_DIR}/" -p "${STAGE_DIR}/plist" -o "${ARCHIVE_DIR}" 

echo "Package created:"
echo "pkg/${PKG_NAME}"
