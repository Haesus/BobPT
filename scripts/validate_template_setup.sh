#!/usr/bin/env bash
set -euo pipefail

ALLOW_TEMPLATE_PLACEHOLDERS=false
if [[ "${1:-}" == "--allow-template-placeholders" ]]; then
  ALLOW_TEMPLATE_PLACEHOLDERS=true
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep(rg)이 필요합니다. 먼저 rg를 설치하세요." >&2
  exit 1
fi

placeholder_pattern='YOUR_TEAM_ID|YOUR_ITC_TEAM_ID|YourOrganization|com\.company\.app|developer@example\.com|your-org'
placeholder_files=(
  'Tuist/ProjectDescriptionHelpers/AppEnv.swift'
  'Xcconfig/Project/dev.xcconfig'
  'Xcconfig/Project/beta.xcconfig'
  'Xcconfig/Project/release.xcconfig'
  'fastlane/Appfile'
  'fastlane/Matchfile'
  'fastlane/Fastfile'
  '.github/workflows/testflight-ci.yml'
)

echo "프로젝트 placeholder 검사를 시작합니다."

set +e
placeholder_result="$(rg -n "$placeholder_pattern" "${placeholder_files[@]}" 2>/dev/null)"
placeholder_status=$?
set -e

if [[ $placeholder_status -eq 0 ]]; then
  echo ""
  echo "아래 template placeholder가 아직 남아 있습니다."
  echo "$placeholder_result"
  if [[ "$ALLOW_TEMPLATE_PLACEHOLDERS" == "true" ]]; then
    echo ""
    echo "--allow-template-placeholders 옵션으로 placeholder 존재를 허용했습니다."
  else
    echo ""
    echo "새 프로젝트에서는 README.md의 Initial Setup Checklist에 맞춰 값을 교체한 뒤 다시 실행하세요."
    exit 1
  fi
elif [[ $placeholder_status -eq 1 ]]; then
  echo "placeholder 검사 통과"
else
  echo "placeholder 검사 중 오류가 발생했습니다." >&2
  exit "$placeholder_status"
fi

required_files=(
  'Tuist/ProjectDescriptionHelpers/AppEnv.swift'
  'Xcconfig/Project/dev.xcconfig'
  'Xcconfig/Project/beta.xcconfig'
  'Xcconfig/Project/release.xcconfig'
  'fastlane/Appfile'
  'fastlane/Matchfile'
  'fastlane/Fastfile'
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "필수 설정 파일이 없습니다: $file" >&2
    exit 1
  fi
done

echo "필수 설정 파일 검사 통과"
echo "템플릿 설정 검사가 완료되었습니다."
