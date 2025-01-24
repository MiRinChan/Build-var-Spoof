#!/bin/sh
PATH=/data/adb/ap/bin:/data/adb/ksu/bin:/data/adb/magisk:/data/data/com.termux/files/usr/bin:$PATH
MODDIR=./
echo "[*] en: script form PlayIntegrityFix, edited for Build var spoof."
echo "[*] zh: 程式由 PlayIntegrityFix 提供, 為 Build var spoof 使用而編輯。"
printf "\n\n"

download() { busybox wget -T 10 --no-check-certificate -qO - "$1"; }
if command -v curl > /dev/null 2>&1; then
	download() { curl --connect-timeout 10 -s "$1"; }
fi

sleep_pause() {
	# APatch and KernelSU needs this
	if [ -z "$MMRL" ] && { [ "$KSU" = "true" ] || [ "$APATCH" = "true" ]; }; then
		sleep 5
	fi
}

set_random_beta() {
    if [ "$(echo "$MODEL_LIST" | wc -l)" -ne "$(echo "$PRODUCT_LIST" | wc -l)" ]; then
        echo "en: Error: MODEL_LIST and PRODUCT_LIST have different lengths."
        echo "zh: 錯誤：MODEL_LIST 和 PRODUCT_LIST 有不同的長度。"
        sleep_pause
        exit 1
    fi
    count=$(echo "$MODEL_LIST" | wc -l)
    rand_index=$(( $$ % count ))
    MODEL=$(echo "$MODEL_LIST" | sed -n "$((rand_index + 1))p")
    PRODUCT=$(echo "$PRODUCT_LIST" | sed -n "$((rand_index + 1))p")
    DEVICE=$(echo "$PRODUCT" | sed 's/_beta//')
}

download_fail() {
	echo "[!] en: download failed!"
	echo "[!] zh: 下載出錯！"
	printf "\n\n"
	echo "[x] en: bailing out!"
	echo "[x] zh: 退出。"
	sleep_pause
	exit 1
}

# lets try to use tmpfs for processing
TEMPDIR="$MODDIR/temp" #fallback
[ -w /sbin ] && TEMPDIR="/sbin/doSomethings"
[ -w /debug_ramdisk ] && TEMPDIR="/debug_ramdisk/doSomethings"
mkdir -p "$TEMPDIR"
cd "$TEMPDIR"

download https://developer.android.com/topic/generic-system-image/releases > PIXEL_GSI_HTML || download_fail
grep -m1 -o 'li>.*(Beta)' PIXEL_GSI_HTML | cut -d\> -f2
grep -m1 -o 'Date:.*' PIXEL_GSI_HTML

RELEASE="$(grep -m1 'corresponding Google Pixel builds' PIXEL_GSI_HTML | grep -o '/versions/.*' | cut -d/ -f3)"
ID="$(grep -m1 -o 'Build:.*' PIXEL_GSI_HTML | cut -d' ' -f2)"
INCREMENTAL="$(grep -m1 -o "$ID-.*-" PIXEL_GSI_HTML | cut -d- -f2)"

download "https://developer.android.com$(grep -m1 'corresponding Google Pixel builds' PIXEL_GSI_HTML | grep -o 'href.*' | cut -d\" -f2)" > PIXEL_GET_HTML || download_fail
download "https://developer.android.com$(grep -m1 'Pixel downloads page' PIXEL_GET_HTML | grep -o 'href.*' | cut -d\" -f2)" > PIXEL_BETA_HTML || download_fail

MODEL_LIST="$(grep -A1 'tr id=' PIXEL_BETA_HTML | grep 'td' | sed 's;.*<td>\(.*\)</td>;\1;')"
PRODUCT_LIST="$(grep -o 'factory/.*_beta' PIXEL_BETA_HTML | cut -d/ -f2)"

download https://source.android.com/docs/security/bulletin/pixel > PIXEL_SECBULL_HTML || download_fail

SECURITY_PATCH="$(grep -A15 "$(grep -m1 -o 'Security patch level:.*' PIXEL_GSI_HTML | cut -d' ' -f4-)" PIXEL_SECBULL_HTML | grep -m1 -B1 '</tr>' | grep 'td' | sed 's;.*<td>\(.*\)</td>;\1;')"

echo "- en: Selecting Pixel Beta device ..."
echo "- zh: 選擇 Pixel 測試版裝置 ..."
[ -z "$PRODUCT" ] && set_random_beta
echo "$MODEL ($PRODUCT)"
printf "\n\n"

sdk_version="$(getprop ro.build.version.sdk)"
sdk_version="${sdk_version:-25}"
echo "en: Device SDK version: $sdk_version"
echo "zh: 裝置 SDK 版本: $sdk_version"
printf "\n\n"

echo "- en: Dumping values to spoof_build_vars ..."
echo "- zh: 填入值到 spoof_build_vars ..."
printf "\n\n"
cat <<EOF | tee spoof_build_vars
MANUFACTURER=Google
MODEL=$MODEL
FINGERPRINT=google/$PRODUCT/$DEVICE:$RELEASE/$ID/$INCREMENTAL:user/release-keys
BRAND=google
PRODUCT=$PRODUCT
DEVICE=$DEVICE
RELEASE=$RELEASE
ID=$ID
INCREMENTAL=$INCREMENTAL
TYPE=user
TAGS=release-keys
SECURITY_PATCH=$SECURITY_PATCH
DEVICE_INITIAL_SDK_INT=$sdk_version
EOF

cat "$TEMPDIR/spoof_build_vars" > /data/adb/build_var_spoof/spoof_build_vars
printf "\n\n"
echo "- en: new spoof_build_vars saved to /data/adb/build_var_spoof/spoof_build_vars"
echo "- zh: 新的 spoof_build_vars 儲存到 /data/adb/build_var_spoof/spoof_build_vars"
printf "\n\n"

echo "- en: Cleaning up ..."
echo "- zh: 清理工作 ..."
rm -rf "$TEMPDIR"

for i in $(busybox pidof com.google.android.gms.unstable); do
	echo "- en: Killing pid $i"
	echo "- zh: 殺死 pid $i"
	printf "\n\n"
	kill -9 "$i"
done

echo "- en: Done!"
echo "- zh: 已完成"
sleep_pause
