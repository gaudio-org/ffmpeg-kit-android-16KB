#!/bin/bash

# BASEDIR 설정
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 FFmpegKit AAR 빌드 시작..."

# 환경 변수 확인
if [[ -z "${ANDROID_SDK_ROOT}" ]]; then
    echo "❌ ANDROID_SDK_ROOT가 설정되지 않았습니다"
    echo "다음 명령어로 설정하세요:"
    echo "export ANDROID_SDK_ROOT=~/Library/Android/sdk"
    exit 1
fi

if [[ -z "${ANDROID_NDK_ROOT}" ]]; then
    echo "❌ ANDROID_NDK_ROOT가 설정되지 않았습니다"
    echo "다음 명령어로 설정하세요:"
    echo "export ANDROID_NDK_ROOT=~/Library/Android/sdk/ndk/23.1.7779620"
    exit 1
fi

echo "✅ 환경 변수 확인 완료"
echo "📁 작업 디렉토리: ${BASEDIR}"

# 1단계: FFmpeg 빌드
echo "📦 1단계: FFmpeg 빌드 중..."
# ./android.sh 스크립트 실행 (전달된 모든 옵션 포함)
"${BASEDIR}/android.sh" "$@"
if [ $? -ne 0 ]; then
    echo "❌ FFmpeg 빌드 실패"
    exit 1
fi
echo "✅ 1단계: FFmpeg 빌드 완료"

# 2단계: JNI 라이브러리 복사
echo "📂 2단계: JNI 라이브러리 복사 중..."
# libs 디렉토리 생성
mkdir -p "${BASEDIR}/android/libs/armeabi-v7a"
mkdir -p "${BASEDIR}/android/libs/arm64-v8a"
mkdir -p "${BASEDIR}/android/libs/x86"
mkdir -p "${BASEDIR}/android/libs/x86_64"

# FFmpeg 라이브러리 복사
cp "${BASEDIR}/prebuilt/android-arm/ffmpeg/lib/"*.so "${BASEDIR}/android/libs/armeabi-v7a/" 2>/dev/null || true
cp "${BASEDIR}/prebuilt/android-arm-neon/ffmpeg/lib/"*.so "${BASEDIR}/android/libs/armeabi-v7a/" 2>/dev/null || true
cp "${BASEDIR}/prebuilt/android-arm64/ffmpeg/lib/"*.so "${BASEDIR}/android/libs/arm64-v8a/" 2>/dev/null || true
cp "${BASEDIR}/prebuilt/android-x86/ffmpeg/lib/"*.so "${BASEDIR}/android/libs/x86/" 2>/dev/null || true
cp "${BASEDIR}/prebuilt/android-x86_64/ffmpeg/lib/"*.so "${BASEDIR}/android/libs/x86_64/" 2>/dev/null || true

# FFmpegKit 핵심 라이브러리 복사
cp "${BASEDIR}/android/ffmpeg-kit-android-lib/src/main/libs/armeabi-v7a/"libffmpegkit*.so "${BASEDIR}/android/libs/armeabi-v7a/" 2>/dev/null || true
cp "${BASEDIR}/android/ffmpeg-kit-android-lib/src/main/libs/arm64-v8a/"libffmpegkit*.so "${BASEDIR}/android/libs/arm64-v8a/" 2>/dev/null || true
cp "${BASEDIR}/android/ffmpeg-kit-android-lib/src/main/libs/x86/"libffmpegkit*.so "${BASEDIR}/android/libs/x86/" 2>/dev/null || true
cp "${BASEDIR}/android/ffmpeg-kit-android-lib/src/main/libs/x86_64/"libffmpegkit*.so "${BASEDIR}/android/libs/x86_64/" 2>/dev/null || true

echo "✅ 2단계: JNI 라이브러리 복사 완료"

# 3단계: Android AAR 빌드
echo "📦 3단계: Android AAR 빌드 중..."
cd "${BASEDIR}/android" && ./gradlew clean assembleRelease
if [ $? -ne 0 ]; then
    echo "❌ Android AAR 빌드 실패"
    exit 1
fi
echo "✅ 3단계: Android AAR 빌드 완료"

echo "🎉 FFmpegKit AAR 빌드 성공!"
echo "AAR 파일 위치: ${BASEDIR}/android/ffmpeg-kit-android-lib/build/outputs/aar/ffmpeg-kit-release.aar"
