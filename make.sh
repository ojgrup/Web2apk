# ... (Fungsi-fungsi log, try, set_var, dll. TIDAK BERUBAH)
# ...

# -----------------------------------------------------------------------------
# GANTI FUNGSI 'apk' DAN 'build' DENGAN KODE BERIKUT
# -----------------------------------------------------------------------------

apk() {
    local build_task="${1:-bundleRelease}" # Default: bundleRelease
    
    # KITA TIDAK LAGI MEMERLUKAN PEREKSAAN KE STORE LOKAL KARENA KITA MENGGUNAKAN GITHUB SECRETS.
    # Namun, kita tambahkan pengecekan Environment Variables (Secrets)
    if [ -z "${MYAPP_RELEASE_STORE_FILE:-}" ]; then
        error "Signing secrets not found. Run this build via GitHub Actions or set environment variables."
    fi

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
        if [ -f "$output_dir/app-release.aab" ]; then
            log "App Bundle successfully built and signed"
            try "cp $output_dir/app-release.aab '$output_file'"
            echo -e "${BOLD}----------------"
            echo -e "Final App Bundle copied to: ${GREEN}$output_file${NC}"
            echo -e "Size: ${BLUE}$(du -h $output_dir/app-release.aab | cut -f1)${NC}"
            echo -e "Package: ${BLUE}com.${appname}.webtoapk${NC}"
            # Log lainnya...
            echo -e "${BOLD}----------------${NC}"
        else
            error "Build failed"
        fi
    else
        # Log untuk build APK/Debug lainnya
        log "$build_task completed (Output not copied)"
    fi
}

# Modifikasi fungsi build untuk memanggil apk() dengan task 'bundleRelease'
build() {
    apply_config $@
    # Panggil fungsi apk dengan task 'bundleRelease' (untuk AAB)
    apk bundleRelease
}

# Modifikasi fungsi debug untuk memanggil apk() dengan task 'assembleDebug'
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
# -----------------------------------------------------------------------------

# ... (Fungsi-fungsi test, keygen, clean, dll. TIDAK BERUBAH)
# ...

# Bagian terakhir make.sh TIDAK BERUBAH

###############################################################################

ORIGINAL_PWD="$PWD"

# ... (Bagian di bawah ini TIDAK BERUBAH)
