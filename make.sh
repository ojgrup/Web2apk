# ... (Fungsi-fungsi di atas fungsi apk TIDAK BERUBAH)
# ...

# -----------------------------------------------------------------------------
# GANTI FUNGSI 'apk' DAN 'build' DENGAN KODE BERIKUT
# -----------------------------------------------------------------------------

apk() {
    local build_task="${1:-bundleRelease}" 
    
    if [ -z "${MYAPP_RELEASE_STORE_FILE:-}" ]; then
        error "Signing secrets not found. Run this build via GitHub Actions or set environment variables."
    fi
    
    # PERBAIKAN: Set output_dir agar sesuai dengan ekspektasi GitHub Actions
    local output_dir="app/build/outputs/bundle/release"
    local output_file="$appname.aab"
    
    # Pastikan direktori sudah bersih
    rm -f "$output_dir/app-release.aab"

    info "Building $build_task..."
    
    # Menjalankan gradlew dan menyuntikkan secrets sebagai Project Properties (-P)
    try "./gradlew :app:$build_task \
        -P MYAPP_RELEASE_STORE_FILE=\"$MYAPP_RELEASE_STORE_FILE\" \
        -P MYAPP_RELEASE_STORE_PASSWORD=\"$MYAPP_RELEASE_STORE_PASSWORD\" \
        -P MYAPP_RELEASE_KEY_ALIAS=\"$MYAPP_RELEASE_KEY_ALIAS\" \
        -P MYAPP_RELEASE_KEY_PASSWORD=\"$MYAPP_RELEASE_KEY_PASSWORD\" \
        --no-daemon --quiet"

    if [ "$build_task" = "bundleRelease" ]; then
        # PERBAIKAN: Periksa AAB yang baru dibuat
        local built_aab_path="$output_dir/app-release.aab"
        
        if [ -f "$built_aab_path" ]; then
            log "App Bundle successfully built and signed"
            
            # Langkah upload artifact di YAML akan menemukan file ini, jadi 
            # kita tidak perlu menyalinnya ke root project kecuali untuk log.
            # try "cp $built_aab_path '$output_file'" 
            
            echo -e "${BOLD}----------------"
            echo -e "Final App Bundle location: ${GREEN}$built_aab_path${NC}"
            echo -e "Size: ${BLUE}$(du -h $built_aab_path | cut -f1)${NC}"
            echo -e "Package: ${BLUE}com.${appname}.webtoapk${NC}"
            echo -e "${BOLD}----------------${NC}"
        else
            error "Build failed: Could not find AAB at $built_aab_path"
        fi
    else
        log "$build_task completed (Output not copied)"
    fi
}

# Fungsi 'build' dan 'debug' TIDAK PERLU DIUBAH LAGI

# ...
