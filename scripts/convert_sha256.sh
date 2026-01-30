#!/bin/bash

# ============================================
# Script: convert_sha256.sh
# Description: แปลง SHA256 จาก HEX format เป็น Base64 format
#              สำหรับใช้กับ freerasp package
# ============================================
# Usage:
#   ./convert_sha256.sh "41:98:22:82:0A:DB:61:CA:20:34:AF:FB:2E:F6:99:DF:E7:44:02:2F:7A:D5:C9:CA:B3:A4:41:CB:DD:AE:1C:F8"
#
# หรือดึง SHA256 จาก keystore โดยตรง:
#   ./convert_sha256.sh --from-keystore path/to/keystore.jks alias_name
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_usage() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  SHA256 HEX to Base64 Converter${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "  1) แปลงจาก HEX string:"
    echo "     ./convert_sha256.sh \"41:98:22:82:0A:DB:61:CA:...\""
    echo ""
    echo "  2) ดึงจาก keystore โดยตรง:"
    echo "     ./convert_sha256.sh --from-keystore <keystore_path> <alias>"
    echo ""
    echo -e "${YELLOW}Example:${NC}"
    echo "  ./convert_sha256.sh \"41:98:22:82:0A:DB:61:CA:20:34:AF:FB:2E:F6:99:DF:E7:44:02:2F:7A:D5:C9:CA:B3:A4:41:CB:DD:AE:1C:F8\""
    echo "  ./convert_sha256.sh --from-keystore android/app/pos-release-key.jks pos-key"
    echo ""
}

convert_hex_to_base64() {
    local hex_input="$1"

    # ลบ : และ spaces ออก แล้วแปลงเป็น lowercase
    local hex_clean=$(echo "$hex_input" | tr -d ':' | tr -d ' ' | tr '[:lower:]' '[:upper:]')

    # ตรวจสอบว่าเป็น HEX string ที่ถูกต้อง (64 characters สำหรับ SHA256)
    if [[ ! "$hex_clean" =~ ^[0-9A-F]{64}$ ]]; then
        echo -e "${RED}❌ Error: Invalid SHA256 HEX format${NC}"
        echo -e "${YELLOW}   Expected: 64 hexadecimal characters${NC}"
        echo -e "${YELLOW}   Got: ${#hex_clean} characters${NC}"
        exit 1
    fi

    # แปลง HEX เป็น Base64
    local base64_result=$(echo "$hex_clean" | xxd -r -p | base64)

    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  ✅ Conversion Successful!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}HEX Input:${NC}"
    echo "  $hex_input"
    echo ""
    echo -e "${YELLOW}Base64 Output (สำหรับใส่ใน rasp_config.dart):${NC}"
    echo -e "  ${GREEN}$base64_result${NC}"
    echo ""
    echo -e "${BLUE}Copy this to signingCertHashes:${NC}"
    echo "  signingCertHashes: ["
    echo "    '$base64_result',"
    echo "  ],"
    echo ""
}

from_keystore() {
    local keystore_path="$1"
    local alias="$2"

    if [ -z "$keystore_path" ] || [ -z "$alias" ]; then
        echo -e "${RED}❌ Error: Missing keystore path or alias${NC}"
        print_usage
        exit 1
    fi

    if [ ! -f "$keystore_path" ]; then
        echo -e "${RED}❌ Error: Keystore file not found: $keystore_path${NC}"
        exit 1
    fi

    echo -e "${BLUE}🔑 Reading SHA256 from keystore...${NC}"
    echo -e "${YELLOW}   Keystore: $keystore_path${NC}"
    echo -e "${YELLOW}   Alias: $alias${NC}"
    echo ""

    # ดึง SHA256 จาก keystore
    local sha256_hex=$(keytool -list -v -keystore "$keystore_path" -alias "$alias" 2>/dev/null | grep "SHA256:" | awk '{print $2}')

    if [ -z "$sha256_hex" ]; then
        echo -e "${YELLOW}⚠️  Enter keystore password:${NC}"
        sha256_hex=$(keytool -list -v -keystore "$keystore_path" -alias "$alias" | grep "SHA256:" | awk '{print $2}')
    fi

    if [ -z "$sha256_hex" ]; then
        echo -e "${RED}❌ Error: Could not extract SHA256 from keystore${NC}"
        echo -e "${YELLOW}   Please check keystore path, alias, and password${NC}"
        exit 1
    fi

    convert_hex_to_base64 "$sha256_hex"
}

# Main
case "$1" in
    --from-keystore|-k)
        from_keystore "$2" "$3"
        ;;
    --help|-h)
        print_usage
        ;;
    "")
        print_usage
        ;;
    *)
        convert_hex_to_base64 "$1"
        ;;
esac
