# make.sh - Fungsi apk yang dimodifikasi

# ... (lanjutkan dari fungsi apply_config)

# --- FUNGSI APK YANG DIPERBAIKI ---
apk() {
    local build_task="${1:-bundleRelease}" 
    
    if [ -z "${MYAPP_RELEASE_STORE_FILE:-}" ]; then
        error "Signing secrets not found. Run this build via GitHub Actions or set environment variables."
    fi
    
    # Path yang diharapkan oleh GitHub Actions untuk output AAB rilis:
    local output_dir="app/build/outputs/bundle/release"
    local output_file="$appname.aab"
    
    # Bersihkan file keluaran lama
    rm -f "$output_dir/app-release.aab"

    info "Building $build_task..."
    
    # PERINTAH KRUSIAL: Menjalankan gradlew dan menyuntikkan secrets sebagai Project Properties (-P)
    try "./gradlew :app:$build_task \
        -P MYAPP_RELEASE_STORE_FILE=\"$MYAPP_RELEASE_STORE_FILE\" \
        -P MYAPP_RELEASE_STORE_PASSWORD=\"$MYAPP_RELEASE_STORE_PASSWORD\" \
        -P MYAPP_RELEASE_KEY_ALIAS=\"$MYAPP_RELEASE_KEY_ALIAS\" \
        -P MYAPP_RELEASE_KEY_PASSWORD=\"$MYAPP_RELEASE_KEY_PASSWORD\" \
        --no-daemon --quiet"

    if [ "$build_task" = "bundleRelease" ]; then
        # Periksa AAB yang baru dibuat (menggunakan find untuk menangani nama file yang mungkin berbeda)
        local built_aab_path=$(find "$output_dir" -name "*.aab" -print -quit)
        
        if [ -n "$built_aab_path" ]; then
            log "App Bundle successfully built and signed"
            
            # Salin ke root untuk log yang lebih jelas di konsol
            try "cp \"$built_aab_path\" \"$output_file\"" 
            
            echo -e "${BOLD}----------------"
            echo -e "Final App Bundle location: ${GREEN}$built_aab_path${NC}"
            echo -e "Size: ${BLUE}$(du -h "$built_aab_path" | cut -f1)${NC}"
            echo -e "Package: ${BLUE}com.${appname}.webtoapk${NC}"
            echo -e "${BOLD}----------------${NC}"
        else
            error "Build failed: Could not find AAB in $output_dir. Check Gradle logs for error."
        fi
    elif [ "$build_task" = "assembleRelease" ]; then
        log "$build_task completed (Output not copied)"
    else
        log "$build_task completed (Output not copied)"
    fi
}
# --- AKHIR FUNGSI APK YANG DIPERBAIKI ---

# ... (lanjutkan dengan fungsi test, keygen, clean, dll.)

# --- FUNGSI BUILD DAN DEBUG YANG DIMODIFIKASI ---
build() {
    apply_config $@
    # Panggil fungsi apk dengan task 'bundleRelease' (untuk AAB)
    apk bundleRelease
}

debug() {
    apply_config $@
    info "Building debug APK..."
    # Panggil fungsi apk dengan task 'assembleDebug'
    apk assembleDebug
    
    if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
        log "Debug APK successfully built"
    else
        error "Debug build failed"
    fi
}
# --- AKHIR FUNGSI BUILD DAN DEBUG YANG DIMODIFIKASI ---

# ... (lanjutkan dengan sisa make.sh)
