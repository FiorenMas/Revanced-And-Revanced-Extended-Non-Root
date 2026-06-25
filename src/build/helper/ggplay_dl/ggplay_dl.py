#!/usr/bin/env python3
#
# Rewritten from: https://gitlab.com/AuroraOSS/AuroraStore
# Licensed under GNU General Public License v3.0
#
"""
Usage:
  python3 ggplay_dl.py <package_name> <output_path> [--dispenser <url>]
"""

import argparse
import hashlib
import json
import os
import random
import sys
import time
import base64

import requests
from google.protobuf import descriptor as _descriptor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ggplay_pb2 import (
    AndroidCheckinRequest,
    AndroidCheckinProto,
    AndroidBuildProto,
    AndroidCheckinResponse,
    DeviceConfigurationProto,
    UploadDeviceConfigRequest,
    ResponseWrapper,
)

DISPENSER_URL = "https://auroraoss.com/api/auth"

URL_BASE = "https://android.clients.google.com"
URL_FDFE = f"{URL_BASE}/fdfe"
URL_CHECK_IN = f"{URL_BASE}/checkin"
URL_AUTH = f"{URL_BASE}/auth"
URL_UPLOAD_DEVICE_CONFIG = f"{URL_FDFE}/uploadDeviceConfig"
URL_DETAILS = f"{URL_FDFE}/details"
URL_PURCHASE = f"{URL_FDFE}/purchase"
URL_DELIVERY = f"{URL_FDFE}/delivery"
URL_ACQUIRE = f"{URL_FDFE}/acquire"

DEVICE_PROPERTIES = {
    "UserReadableName": "Google Pixel 9a",
    "Build.DEVICE": "tegu",
    "Build.MODEL": "Pixel 9a",
    "Build.MANUFACTURER": "Google",
    "Build.BRAND": "google",
    "Build.PRODUCT": "tegu",
    "Build.HARDWARE": "tegu",
    "Build.FINGERPRINT": "google/tegu/tegu:15/BD4A.250405.003/13238919:user/release-keys",
    "Build.VERSION.SDK_INT": "35",
    "Build.VERSION.RELEASE": "15",
    "Build.ID": "BD4A.250405.003",
    "Build.BOOTLOADER": "tegu-16.0-13238451",
    "Build.RADIO": "g5300t-241101-241226-B-12850354",
    "GSF.version": "251333035",
    "Vending.version": "84582130",
    "Vending.versionString": "45.8.21-31 [0] [PR] 747433787",
    "Client": "android-google",
    "SimOperator": "38",
    "CellOperator": "310",
    "Screen.Density": "420",
    "Screen.Width": "1080",
    "Screen.Height": "2424",
    "Platforms": "arm64-v8a",
    "Features": "android.hardware.bluetooth,android.hardware.camera,android.hardware.location,android.hardware.microphone,android.hardware.nfc,android.hardware.screen.landscape,android.hardware.screen.portrait,android.hardware.telephony,android.hardware.touchscreen,android.hardware.wifi",
    "Locales": "en_US",
    "SharedLibraries": "",
    "TouchScreen": "3",
    "Keyboard": "1",
    "Navigation": "1",
    "ScreenLayout": "2",
    "HasHardKeyboard": "false",
    "HasFiveWayNavigation": "false",
    "GL.Version": "196610",
    "GL.Extensions": "",
    "TimeZone": "UTC-0",
    "Roaming": "mobile-notroaming",
}


def build_device_config():
    config = DeviceConfigurationProto()
    config.touchScreen = int(DEVICE_PROPERTIES["TouchScreen"])
    config.keyboard = int(DEVICE_PROPERTIES["Keyboard"])
    config.navigation = int(DEVICE_PROPERTIES["Navigation"])
    config.screenLayout = int(DEVICE_PROPERTIES["ScreenLayout"])
    config.hasHardKeyboard = DEVICE_PROPERTIES["HasHardKeyboard"] == "true"
    config.hasFiveWayNavigation = DEVICE_PROPERTIES["HasFiveWayNavigation"] == "true"
    config.screenDensity = int(DEVICE_PROPERTIES["Screen.Density"])
    config.glEsVersion = int(DEVICE_PROPERTIES["GL.Version"])
    config.screenWidth = int(DEVICE_PROPERTIES["Screen.Width"])
    config.screenHeight = int(DEVICE_PROPERTIES["Screen.Height"])

    for platform in DEVICE_PROPERTIES["Platforms"].split(","):
        config.nativePlatform.append(platform.strip())

    for feature in DEVICE_PROPERTIES["Features"].split(","):
        if feature.strip():
            config.systemAvailableFeature.append(feature.strip())

    for locale in DEVICE_PROPERTIES["Locales"].split(","):
        if locale.strip():
            config.systemSupportedLocale.append(locale.strip())

    for lib in DEVICE_PROPERTIES["SharedLibraries"].split(","):
        if lib.strip():
            config.systemSharedLibrary.append(lib.strip())

    for ext in DEVICE_PROPERTIES["GL.Extensions"].split(","):
        if ext.strip():
            config.glExtension.append(ext.strip())

    return config


def build_checkin_request():
    build = AndroidBuildProto()
    build.device = DEVICE_PROPERTIES["Build.DEVICE"]
    build.model = DEVICE_PROPERTIES["Build.MODEL"]
    build.manufacturer = DEVICE_PROPERTIES["Build.MANUFACTURER"]
    build.product = DEVICE_PROPERTIES["Build.PRODUCT"]
    build.buildProduct = DEVICE_PROPERTIES["Build.PRODUCT"]
    build.client = DEVICE_PROPERTIES["Client"]
    build.id = DEVICE_PROPERTIES["Build.ID"]
    build.bootloader = DEVICE_PROPERTIES["Build.BOOTLOADER"]
    build.radio = DEVICE_PROPERTIES["Build.RADIO"]
    build.timestamp = int(time.time() * 1000)
    build.sdkVersion = int(DEVICE_PROPERTIES["Build.VERSION.SDK_INT"])
    build.googleServices = int(DEVICE_PROPERTIES["GSF.version"])

    checkin = AndroidCheckinProto()
    checkin.build.CopyFrom(build)
    checkin.lastCheckinMsec = 0
    checkin.cellOperator = DEVICE_PROPERTIES["CellOperator"]
    checkin.simOperator = DEVICE_PROPERTIES["SimOperator"]
    checkin.roaming = DEVICE_PROPERTIES["Roaming"]
    checkin.userNumber = 0

    device_config = build_device_config()

    request = AndroidCheckinRequest()
    request.checkin.CopyFrom(checkin)
    request.timeZone = DEVICE_PROPERTIES["TimeZone"]
    request.locale = "en-US"
    request.version = 3
    request.deviceConfiguration.CopyFrom(device_config)

    return request.SerializeToString()


def build_upload_device_config_request():
    request = UploadDeviceConfigRequest()
    request.deviceConfiguration.CopyFrom(build_device_config())
    request.manufacturer = DEVICE_PROPERTIES["Build.MANUFACTURER"]
    return request.SerializeToString()


def build_acquire_request(package_name, version_code, offer_type):
    def encode_varint(value):
        bits = value & 0x7f
        value >>= 7
        result = b""
        while value:
            result += bytes([0x80 | bits])
            bits = value & 0x7f
            value >>= 7
        result += bytes([bits])
        return result

    def encode_field(field_number, wire_type, data):
        tag = (field_number << 3) | wire_type
        return encode_varint(tag) + data

    def encode_varint_field(field_number, value):
        return encode_field(field_number, 0, encode_varint(value))

    def encode_string_field(field_number, value):
        encoded = value.encode("utf-8")
        return encode_field(field_number, 2, encode_varint(len(encoded)) + encoded)

    def encode_length_delimited_field(field_number, sub_message_bytes):
        return encode_field(field_number, 2, encode_varint(len(sub_message_bytes)) + sub_message_bytes)

    payload = b""
    payload += encode_varint_field(2, 1)
    payload += encode_varint_field(3, 3)
    payload += encode_string_field(4, package_name)

    package = b""
    package += encode_length_delimited_field(1, payload)
    package += encode_varint_field(2, 1)

    version = b""
    version += encode_varint_field(1, version_code)
    version += encode_varint_field(3, 0)

    msg30 = b""
    msg30 += encode_varint_field(1, 2)
    msg30 += encode_varint_field(2, 0)

    nonce_bytes = bytes(random.getrandbits(8) for _ in range(256))
    nonce = base64.urlsafe_b64encode(nonce_bytes).rstrip(b"=").decode("ascii")

    request = b""
    request += encode_length_delimited_field(1, package)
    request += encode_length_delimited_field(2, version)
    request += encode_varint_field(15, 0)
    request += encode_varint_field(16, offer_type)
    request += encode_string_field(20, f"nonce={nonce}")
    request += encode_varint_field(25, 2)
    request += encode_length_delimited_field(30, msg30)

    return request


FLARESOLVERR_URL = "http://localhost:8191/v1"
SOCKS5_PROXY = "socks5://127.0.0.1:9099"


def _detect_socks5():
    import socket
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(2)
        s.connect(("127.0.0.1", 9099))
        s.close()
        return SOCKS5_PROXY
    except Exception:
        return None


class GooglePlaySession:

    def __init__(self, dispenser_url=None):
        self.dispenser_url = dispenser_url or DISPENSER_URL
        self.flaresolverr_url = self._detect_flaresolverr()
        self.socks5_proxy = _detect_socks5()
        self.email = None
        self.aas_token = None
        self.gsf_id = None
        self.auth_token = None
        self.device_checkin_consistency_token = None
        self.device_config_token = None
        self.session = requests.Session()
        if self.socks5_proxy:
            import socks
            self.session.proxies = {
                "http": self.socks5_proxy,
                "https": self.socks5_proxy,
            }
            print(f"[+] Using SOCKS5 proxy: {self.socks5_proxy}", file=sys.stderr)
        self.session.headers.update({
            "User-Agent": "com.aurora.store-4.8.3-75",
        })

    def _get_auth_headers(self):
        headers = {
            "app": "com.google.android.gms",
            "User-Agent": f"GoogleAuth/1.4 ({DEVICE_PROPERTIES['Build.DEVICE']} {DEVICE_PROPERTIES['Build.ID']})",
        }
        if self.gsf_id:
            headers["device"] = self.gsf_id
        return headers

    def _get_default_headers(self):
        ua = (
            f"Android-Finsky/{DEVICE_PROPERTIES['Vending.versionString']} "
            f"(api=3,versionCode={DEVICE_PROPERTIES['Vending.version']},"
            f"sdk={DEVICE_PROPERTIES['Build.VERSION.SDK_INT']},"
            f"device={DEVICE_PROPERTIES['Build.DEVICE']},"
            f"hardware={DEVICE_PROPERTIES['Build.HARDWARE']},"
            f"product={DEVICE_PROPERTIES['Build.PRODUCT']},"
            f"platformVersionRelease={DEVICE_PROPERTIES['Build.VERSION.RELEASE']},"
            f"model={DEVICE_PROPERTIES['Build.MODEL']},"
            f"buildId={DEVICE_PROPERTIES['Build.ID']},"
            f"isWideScreen=0,supportedAbis={DEVICE_PROPERTIES['Platforms']})"
        )
        headers = {
            "Authorization": f"Bearer {self.auth_token}",
            "User-Agent": ua,
            "X-DFE-Device-Id": self.gsf_id,
            "Accept-Language": "en-US",
            "X-DFE-Encoded-Targets": (
                "CAESN/qigQYC2AMBFfUbyA7SM5Ij/CvfBoIDgxHqGP8R3xzIBvoQtBKFDZ4HAY4FrwSVMasHBOO2Q8akgYRAQECAQO7AQEpKZ0CnwECAwRrAQYBr9PPAoK7sQMBAQMCBAkIDAgBAwEDBAICBAUZEgMEBAMLAQEBBQEBAcYBARYED+cBfS8CHQEKkAEMMxcBIQoUDwYHIjd3DQ4MFk0JWGYZEREYAQOLAYEBFDMIEYMBAgICAgICOxkCD18LGQKEAcgDBIQBAgGLARkYCy8oBTJlBCUocxQn0QUBDkkGxgNZQq0BZSbeAmIDgAEBOgGtAaMCDAOQAZ4BBIEBKUtQUYYBQscDDxPSARA1oAEHAWmnAsMB2wFyywGLAxol+wImlwOOA80CtwN26A0WjwJVbQEJPAH+BRDeAfkHK/ABASEBCSAaHQemAzkaRiu2Ad8BdXeiAwEBGBUBBN4LEIABK4gB2AFLfwECAdoENq0CkQGMBsIBiQEtiwGgA1zyAUQ4uwS8AwhsvgPyAcEDF27vApsBHaICGhl3GSKxAR8MC6cBAgItmQYG9QIeywLvAeYBDArLAh8HASI4ELICDVmVBgsY/gHWARtcAsMBpALiAdsBA7QBpAJmIArpByn0AyAKBwHTARIHAX8D+AMBcRIBBbEDmwUBMacCHAciNp0BAQF0OgQLJDuSAh54kwFSP0eeAQQ4M5EBQgMEmwFXywFo0gFyWwMcapQBBugBPUW2AVgBKmy3AR6PAbMBGQxrUJECvQR+8gFoWDsYgQNwRSczBRXQAgtRswEW0ALMAREYAUEBIG6yATYCRE8OxgER8gMBvQEDRkwLc8MBTwHZAUOnAXiiBakDIbYBNNcCIUmuArIBSakBrgFHKs0EgwV/G3AD0wE6LgECtQJ4xQFwFbUCjQPkBS6vAQqEAUZF3QIM9wEhCoYCQhXsBCyZArQDugIziALWAdIBlQHwBdUErQE6qQaSA4EEIvYBHir9AQVLmgMCApsCKAwHuwgrENsBAjNYswEVmgIt7QJnN4wDEnta+wGfAcUBxgEtEFXQAQWdAUAeBcwBAQM7rAEJATJ0LENrdh73A6UBhAE+qwEeASxLZUMhDREuH0CGARbd7K0GlQo"
            ),
            "X-DFE-Phenotype": (
                "H4sIAAAAAAAAB3OO3KjMAAA0KRNuWXukBkBQkAJ2MhgAZb5u2GCwQZbCH_EJ77QHmgvtDtbv-Z9_H63zXXU0NVPB1odlyGy7751Q3CitlPDvFd8lxhz3tpNmz7P92CFw73zdHU2Ie0Ad2kmR8lxhiErTFLt3RPGfJQHSDy7Clw0bg8kqf2owLokN4SecJTLoSwBnzQSd652_MOf2d1vKBNVedzg4ciPoLz2mQ8efGAgYeLou-l-PXn_7Sa1MfhHuySxt-4esulEDp8Sbq54CPPKjpANW-lkU2IZ0F92LBI-ukCKSptqeq1eXU96LD9nZfhKHdtjSwJqUm_2r6pMHOxk01saVanmNopjX3YxQafC4iC6T55aRbC8nTI98AF_kItIQAJb5EQxnKTO7TZDWnr01HVPxelb9A2OWX6poidMWl16K54kcu_jhXw-JSBQkVcD_fPsLSZu6joIBAAA"
            ),
            "X-DFE-Client-Id": "am-android-google",
            "X-DFE-Network-Type": "4",
            "X-DFE-Content-Filters": "",
            "X-Limit-Ad-Tracking-Enabled": "false",
            "X-Ad-Id": "",
            "X-DFE-UserLanguages": "en_US",
            "X-DFE-Request-Params": "timeoutMs=4000",
        }
        if self.device_checkin_consistency_token:
            headers["X-DFE-Device-Checkin-Consistency-Token"] = self.device_checkin_consistency_token
        if self.device_config_token:
            headers["X-DFE-Device-Config-Token"] = self.device_config_token
        return headers

    def _get_auth_params(self):
        params = {
            "androidId": self.gsf_id,
            "sdk_version": DEVICE_PROPERTIES["Build.VERSION.SDK_INT"],
            "Email": self.email,
            "google_play_services_version": "251333035",
            "device_country": "us",
            "lang": "en",
            "callerSig": "38918a453d07199354f8b19af05ec6562ced5788",
        }
        return params

    def _get_token_params(self):
        params = self._get_auth_params()
        params.update({
            "app": "com.android.vending",
            "client_sig": "38918a453d07199354f8b19af05ec6562ced5788",
            "callerPkg": "com.google.android.gms",
            "Token": self.aas_token,
            "oauth2_foreground": "1",
            "token_request_options": "CAA4AVAB",
            "check_email": "1",
            "system_partition": "1",
            "droidguard_results": "null",
            "service": "oauth2:https://www.googleapis.com/auth/googleplay",
        })
        return params

    def _detect_flaresolverr(self):
        try:
            resp = requests.get(FLARESOLVERR_URL.replace("/v1", "/"), timeout=3)
            if resp.status_code == 200:
                print(f"[+] FlareSolverr detected at {FLARESOLVERR_URL}", file=sys.stderr)
                return FLARESOLVERR_URL
        except Exception:
            pass
        return None

    def _fs_get_cookies(self):
        for url in [self.dispenser_url, "https://auroraoss.com/"]:
            try:
                resp = requests.post(
                    self.flaresolverr_url,
                    json={"cmd": "request.get", "url": url, "maxTimeout": 60000, "returnOnlyCookies": True},
                    timeout=90,
                )
                resp.raise_for_status()
                data = resp.json()
                if data.get("status") == "ok":
                    cookies = {}
                    for c in data.get("solution", {}).get("cookies", []):
                        cookies[c["name"]] = c["value"]
                    ua = data.get("solution", {}).get("userAgent", "")
                    if cookies:
                        return cookies, ua
            except Exception as e:
                print(f"[!] FlareSolverr failed for {url}: {e}", file=sys.stderr)
        return {}, ""

    def _post_dispenser(self, url, json_data):
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json, text/plain, */*",
            "Accept-Language": "en-US,en;q=0.9",
            "Origin": "https://auroraoss.com",
            "Referer": "https://auroraoss.com/",
        }
        proxies = {}
        if self.socks5_proxy:
            proxies = {"https": self.socks5_proxy, "http": self.socks5_proxy}
        resp = self.session.post(url, json=json_data, headers=headers, proxies=proxies, timeout=30)
        if resp.status_code == 403:
            if self.flaresolverr_url:
                print(f"[!] Direct request blocked (403), trying FlareSolverr...", file=sys.stderr)
                cookies, fs_ua = self._fs_get_cookies()
                if cookies:
                    print(f"[+] Got {len(cookies)} cookies from FlareSolverr", file=sys.stderr)
                    resp = self.session.post(url, json=json_data, headers=headers, cookies=cookies, proxies=proxies, timeout=30)
        resp.raise_for_status()
        return resp.json()

    def step1_get_dispenser_credentials(self):
        print("[+] Step 1: Getting dispenser credentials...", file=sys.stderr)
        data = self._post_dispenser(self.dispenser_url, DEVICE_PROPERTIES)
        self.email = data.get("email")
        self.auth_token = data.get("authToken") or data.get("auth")
        if not self.email or not self.auth_token:
            raise Exception(f"Dispenser returned invalid data: {data}")
        print(f"[+] Got credentials for: {self.email}", file=sys.stderr)

    def step2_checkin(self):
        print("[+] Step 2: Performing checkin...", file=sys.stderr)
        request_bytes = build_checkin_request()
        headers = self._get_auth_headers()
        headers["Content-Type"] = "application/x-protobuffer"
        headers["Host"] = "android.clients.google.com"

        resp = self.session.post(URL_CHECK_IN, data=request_bytes, headers=headers, timeout=30)
        resp.raise_for_status()

        response = AndroidCheckinResponse()
        response.ParseFromString(resp.content)

        self.gsf_id = format(response.androidId, "x")
        self.device_checkin_consistency_token = response.deviceCheckinConsistencyToken
        print(f"[+] GSF ID: {self.gsf_id}", file=sys.stderr)

    def step3_upload_device_config(self):
        print("[+] Step 3: Uploading device config...", file=sys.stderr)
        request_bytes = build_upload_device_config_request()
        headers = self._get_default_headers()
        headers["Content-Type"] = "application/x-protobuffer"

        resp = self.session.post(URL_UPLOAD_DEVICE_CONFIG, data=request_bytes, headers=headers, timeout=30)
        resp.raise_for_status()

        wrapper = ResponseWrapper()
        wrapper.ParseFromString(resp.content)

        if wrapper.HasField("payload"):
            payload = wrapper.payload
            if payload.HasField("uploadDeviceConfigResponse"):
                self.device_config_token = payload.uploadDeviceConfigResponse.uploadDeviceConfigToken

        print(f"[+] Device config token: {self.device_config_token[:30]}..." if self.device_config_token else "[!] No device config token", file=sys.stderr)

    def step4_generate_token(self):
        print("[+] Step 4: Generating OAuth token...", file=sys.stderr)
        headers = self._get_auth_headers()
        headers["app"] = "com.google.android.gms"
        params = self._get_token_params()

        resp = self.session.post(URL_AUTH, data=params, headers=headers, timeout=30)
        resp.raise_for_status()

        response_text = resp.text
        auth_token = None
        for line in response_text.split("\n"):
            if line.startswith("Auth="):
                auth_token = line[5:].strip()
                break

        if not auth_token:
            for part in response_text.split("&"):
                if part.startswith("Auth="):
                    auth_token = part[5:].strip()
                    break

        if not auth_token:
            raise Exception(f"Failed to generate OAuth token. Response: {response_text[:500]}")

        self.auth_token = auth_token
        print(f"[+] OAuth token obtained", file=sys.stderr)

    def step5_get_app_details(self, package_name):
        print(f"[+] Step 5: Getting details for {package_name}...", file=sys.stderr)
        headers = self._get_default_headers()
        params = {"doc": package_name}

        resp = self.session.get(URL_DETAILS, params=params, headers=headers, timeout=30)
        resp.raise_for_status()

        wrapper = ResponseWrapper()
        wrapper.ParseFromString(resp.content)

        if not wrapper.HasField("payload") or not wrapper.payload.HasField("detailsResponse"):
            raise Exception("No detailsResponse in payload")

        details = wrapper.payload.detailsResponse
        if not details.HasField("item"):
            raise Exception("No item in detailsResponse")

        item = details.item
        version_code = 0
        offer_type = 1

        if item.HasField("details") and item.details.HasField("appDetails"):
            version_code = item.details.appDetails.versionCode

        if len(item.offer) > 0:
            offer_type = item.offer[0].offerType

        if version_code == 0:
            raise Exception(f"Could not find versionCode for {package_name}")

        print(f"[+] versionCode={version_code}, offerType={offer_type}", file=sys.stderr)
        return version_code, offer_type

    def step6_purchase(self, package_name, version_code, offer_type):
        print(f"[+] Step 6: Purchasing {package_name} v{version_code}...", file=sys.stderr)

        try:
            acquire_bytes = build_acquire_request(package_name, version_code, offer_type)
            headers = self._get_default_headers()
            headers["Content-Type"] = "application/x-protobuf"
            self.session.post(URL_ACQUIRE, data=acquire_bytes, headers=headers, timeout=30)
        except Exception:
            print("[!] Acquire failed (non-critical), continuing...", file=sys.stderr)

        headers = self._get_default_headers()
        params = {
            "ot": str(offer_type),
            "doc": package_name,
            "vc": str(version_code),
        }
        resp = self.session.post(URL_PURCHASE, params=params, headers=headers, timeout=30)
        resp.raise_for_status()

        wrapper = ResponseWrapper()
        wrapper.ParseFromString(resp.content)

        delivery_token = ""
        if wrapper.HasField("payload") and wrapper.payload.HasField("buyResponse"):
            delivery_token = wrapper.payload.buyResponse.encodedDeliveryToken

        if not delivery_token:
            raise Exception("Failed to get delivery token")

        print(f"[+] Delivery token obtained", file=sys.stderr)

        headers = self._get_default_headers()
        params = {
            "ot": str(offer_type),
            "doc": package_name,
            "vc": str(version_code),
            "dtok": delivery_token,
        }
        resp = self.session.get(URL_DELIVERY, params=params, headers=headers, timeout=30)
        resp.raise_for_status()

        wrapper = ResponseWrapper()
        wrapper.ParseFromString(resp.content)

        if not wrapper.HasField("payload") or not wrapper.payload.HasField("deliveryResponse"):
            raise Exception("No deliveryResponse in payload")

        delivery = wrapper.payload.deliveryResponse

        if delivery.status != 1:
            error_map = {2: "AppNotSupported", 3: "AppNotPurchased", 7: "AppRemoved", 9: "AppNotSupported"}
            error_name = error_map.get(delivery.status, f"Unknown({delivery.status})")
            raise Exception(f"Delivery failed with status {delivery.status}: {error_name}")

        if not delivery.HasField("appDeliveryData"):
            raise Exception("No appDeliveryData in delivery response")

        app_data = delivery.appDeliveryData
        download_url = app_data.downloadUrl
        download_size = app_data.downloadSize
        sha256 = None
        if app_data.sha256:
            try:
                sha256 = base64.urlsafe_b64decode(app_data.sha256 + "==").hex()
            except Exception:
                sha256 = app_data.sha256

        splits = []
        for split in app_data.splitDeliveryData:
            splits.append({
                "name": split.name,
                "downloadUrl": split.downloadUrl,
                "downloadSize": split.downloadSize,
            })

        if splits:
            print(f"[+] Download URL obtained (size={download_size}, splits={len(splits)})", file=sys.stderr)
        else:
            print(f"[+] Download URL obtained (size={download_size})", file=sys.stderr)
        return download_url, download_size, sha256, splits

    def build_session(self):
        self.step1_get_dispenser_credentials()
        self.step2_checkin()

    def _download_file(self, url, dest):
        resp = self.session.get(url, stream=True, timeout=120)
        resp.raise_for_status()
        sha256_hash = hashlib.sha256()
        total = 0
        with open(dest, "wb") as f:
            for chunk in resp.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)
                    sha256_hash.update(chunk)
                    total += len(chunk)
        return total, sha256_hash.hexdigest()

    def download_apk(self, package_name, output_path):
        self.build_session()
        version_code, offer_type = self.step5_get_app_details(package_name)
        download_url, download_size, expected_sha256, splits = self.step6_purchase(
            package_name, version_code, offer_type
        )

        is_split = len(splits) > 0

        if is_split:
            import zipfile
            import tempfile
            print(f"[+] Split APK detected ({len(splits)} splits)", file=sys.stderr)
            tmp_dir = tempfile.mkdtemp()
            base_apk = os.path.join(tmp_dir, "base.apk")
            print(f"[+] Downloading base APK...", file=sys.stderr)
            total, _ = self._download_file(download_url, base_apk)
            print(f"[+] Downloaded base APK ({total} bytes)", file=sys.stderr)
            for i, split in enumerate(splits):
                split_name = split["name"]
                split_dest = os.path.join(tmp_dir, split_name)
                print(f"[+] Downloading split {i+1}/{len(splits)}: {split_name}...", file=sys.stderr)
                total, _ = self._download_file(split["downloadUrl"], split_dest)
                print(f"[+] Downloaded {split_name} ({total} bytes)", file=sys.stderr)
            print(f"[+] Packaging splits into {output_path}...", file=sys.stderr)
            with zipfile.ZipFile(output_path, "w", zipfile.ZIP_DEFLATED) as zf:
                zf.write(base_apk, "base.apk")
                for split in splits:
                    zf.write(os.path.join(tmp_dir, split["name"]), split["name"])
            total_size = os.path.getsize(output_path)
            for f in os.listdir(tmp_dir):
                os.remove(os.path.join(tmp_dir, f))
            os.rmdir(tmp_dir)
            print(f"[+] Packaged {len(splits)+1} APKs into {output_path} ({total_size} bytes)", file=sys.stderr)
            result = {
                "success": True,
                "package": package_name,
                "versionCode": version_code,
                "offerType": offer_type,
                "size": total_size,
                "sha256": "",
                "isSplit": True,
                "outputPath": output_path,
            }
            print(json.dumps(result))
            return output_path

        print(f"[+] Downloading APK to {output_path}...", file=sys.stderr)
        resp = self.session.get(download_url, stream=True, timeout=120)
        resp.raise_for_status()

        sha256_hash = hashlib.sha256()
        total = 0
        with open(output_path, "wb") as f:
            for chunk in resp.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)
                    sha256_hash.update(chunk)
                    total += len(chunk)

        actual_sha256 = sha256_hash.hexdigest()
        if expected_sha256 and actual_sha256 != expected_sha256:
            print(f"[!] SHA256 mismatch: expected {expected_sha256}, got {actual_sha256}", file=sys.stderr)
            os.remove(output_path)
            raise Exception("SHA256 verification failed")

        print(f"[+] Downloaded {total} bytes to {output_path}", file=sys.stderr)
        if expected_sha256:
            print(f"[+] SHA256 verified: {actual_sha256}", file=sys.stderr)

        result = {
            "success": True,
            "package": package_name,
            "versionCode": version_code,
            "offerType": offer_type,
            "downloadUrl": download_url,
            "size": total,
            "sha256": actual_sha256,
            "isSplit": False,
            "outputPath": output_path,
        }
        print(json.dumps(result))
        return output_path


def main():
    parser = argparse.ArgumentParser(description="Download APK from Google Play Store")
    parser.add_argument("package_name", help="Android package name (e.g., com.android.chrome)")
    parser.add_argument("output_path", help="Output file path for the APK")
    parser.add_argument("--dispenser", help="Dispenser URL (default: AuroraStore dispenser)")
    args = parser.parse_args()

    try:
        session = GooglePlaySession(dispenser_url=args.dispenser)
        session.download_apk(args.package_name, args.output_path)
    except Exception as e:
        print(f"[-] Error: {e}", file=sys.stderr)
        result = {"success": False, "error": str(e)}
        print(json.dumps(result))
        sys.exit(1)


if __name__ == "__main__":
    main()
