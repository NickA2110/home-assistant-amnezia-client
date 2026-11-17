#!/usr/bin/with-contenv bashio
set -euo pipefail

declare configuration
declare config_dir="/etc/amnezia/amneziawg"
declare config_file="${config_dir}/awg0.conf"

umask 077
mkdir -p "${config_dir}" /run/amneziawg

configuration="$(bashio::config 'configuration')"
if [[ -z "${configuration//[[:space:]]/}" ]]; then
    bashio::exit.nok "The AmneziaWG configuration is empty"
fi

# Never print this value: it contains the interface private key.
configuration="${configuration//$'\r'/}"
printf '%s\n' "${configuration}" > "${config_file}"
chmod 600 "${config_file}"

if ! validate-awg-config "${config_file}"; then
    bashio::exit.nok "Invalid or unsafe AmneziaWG configuration"
fi

if ! prepare-resolvconf "${config_file}"; then
    bashio::exit.nok "Could not prepare DNS management for AmneziaWG"
fi

bashio::log.info "AmneziaWG configuration validated"
