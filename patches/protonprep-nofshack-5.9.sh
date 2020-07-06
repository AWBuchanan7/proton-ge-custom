#!/bin/bash

#TKG patch order:

#549 clock monotonic
#567 bypass compositor
#718 vulkan childwindow
#1044 fsync staging
#1066 fsync spincount
#1078 fs hack
#1125 rawinput
#1207 LAA
#1221 winex11-MWM
#1229 steam client swap
#1236 protonify rpc
#1237 protonify
#1239 steam bits
#1332 SDL
#1333 SDL2
#1339 gamepad additions
#1375 vr
#1386 vk bits
#1387 fs hack integer scaling
#1391 winevulkan
#1396 msvcrt native builtin
#1411 win10
#1417 dxvk_config

    cd gst-plugins-ugly
    git reset --hard HEAD
    git clean -xdf
    echo "add Guy's patch to fix wmv playback in gst-plugins-ugly"
    patch -Np1 < ../patches/gstreamer/asfdemux-always_re-initialize_metadata_and_global_metadata.patch
    patch -Np1 < ../patches/gstreamer/asfdemux-Re-initialize_demux-adapter_in_gst_asf_demux_reset.patch
    patch -Np1 < ../patches/gstreamer/asfdemux-Only_forward_SEEK_event_when_in_push_mode.patch
    patch -Np1 < ../patches/gstreamer/asfdemux-gst_asf_demux_reset_GST_FORMAT_TIME_fix.patch
    cd ..

    # warframe controller fix
    git checkout lsteamclient
    cd lsteamclient
    patch -Np1 < ../patches/proton-hotfixes/steamclient-disable_SteamController007_if_no_controller.patch
    patch -Np1 < ../patches/proton-hotfixes/steamclient-use_standard_dlopen_instead_of_the_libwine_wrappers.patch
    cd ..

    # vrclient
    git checkout vrclient_x64
    cd vrclient_x64
    patch -Np1 < ../patches/proton-hotfixes/vrclient-use_standard_dlopen_instead_of_the_libwine_wrappers.patch
    cd ..

    # VKD3D patches
    cd vkd3d
    git reset --hard HEAD
    git clean -xdf
    cd ..

    # Valve DXVK patches
    cd dxvk
    git reset --hard HEAD
    git clean -xdf
    patch -Np1 < ../patches/dxvk/valve-dxvk-avoid-spamming-log-with-requests-for-IWineD3D11Texture2D.patch
    patch -Np1 < ../patches/dxvk/proton-add_new_dxvk_config_library.patch
    patch -Np1 < ../patches/dxvk/dxvk-async.patch
    cd ..

    #WINE STAGING
    cd wine-staging
    git reset --hard HEAD
    git clean -xdf
    cd ..

    #WINE
    cd wine
    git reset --hard HEAD
    git clean -xdf

    # this conflicts with proton's gamepad changes and causes camera spinning
    git revert --no-commit da7d60bf97fb8726828e57f852e8963aacde21e9
    

# disable these when using proton's gamepad patches
#    -W dinput-SetActionMap-genre \
#    -W dinput-axis-recalc \
#    -W dinput-joy-mappings \
#    -W dinput-reconnect-joystick \
#    -W dinput-remap-joystick \

    echo "applying staging patches"
    ../wine-staging/patches/patchinstall.sh DESTDIR="." --all \
    -W server-Desktop_Refcount \
    -W ws2_32-TransmitFile \
    -W dinput-SetActionMap-genre \
    -W dinput-axis-recalc \
    -W dinput-joy-mappings \
    -W dinput-reconnect-joystick \
    -W dinput-remap-joystick \
    -W user32-window-activation
    
    
    echo "5.10 backports"
    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/25e9e91c3a4f6c1c134d96a5c11517178e31f111.patch
    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/4ed26b63ca0305ba750c4f38002cf1eb674f688c.patch
    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/ea9b507380b4415cf9edd3643d9bcea7ab934fbd.patch
    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/c96fa96c167808bf1c9a42b72c9e7ab6567eca75.patch

    echo "winhttp backports"
    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/winhttp_backports.patch

    echo "game fix backports"
    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/ashes_of_the_singularity.patch
    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/sc_dos2_poe-multithread.patch
    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/mgs-ground-zeroes.patch
    
    echo "vulkan backports"
    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/winevulkan-1.2.142.patch
    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/winevulkan-change_blacklist_to_more_neutral_word.patch
    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/winevulkan-thunk_vkgetphysicaldeviceproperties2_and_vkgetphysicaldeviceproperties2khr.patch
    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/winevulkan-fill_vulkan_device_LUID_property.patch
    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/winevulkan-1.2.145.patch
    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/winevulkan-dont_initialize_vulkan_driver_in_dllmain.patch
    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/winevulkan_poe_backport.patch
    
    echo "planet zoo/jurassic world hotfixes pending"
    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/planet-zoo-jurassic-world-pending-upstream-staging.patch

    echo "Indiana Jones and the Emperor's Tomb pending"
    patch -Np1 < ../patches/wine-hotfixes/pending/indiana_jones_fix.patch

    #WINE FAUDIO
    #echo "applying faudio patches"
    #patch -Np1 < ../patches/faudio/faudio-ffmpeg.patch
    
    ### GAME PATCH SECTION ###

    #fix this
    echo "mech warrior online"
    patch -Np1 < ../patches/game-patches/mwo.patch

    echo "final fantasy XV denuvo fix"
    patch -Np1 < ../patches/game-patches/ffxv-steam-fix.patch

    echo "final fantasy XIV old launcher render fix"
    patch -Np1 < ../patches/game-patches/ffxiv-launcher.patch

    echo "assetto corsa"
    patch -Np1 < ../patches/game-patches/assettocorsa-hud.patch

    echo "sword art online"
    patch -Np1 < ../patches/game-patches/sword-art-online-gnutls.patch

    echo "origin downloads fix" 
    patch -Np1 < ../patches/game-patches/origin-downloads_fix.patch

    echo "fix steep"
    patch -Np1 < ../patches/game-patches/steep_fix.patch

    echo "rawinput virtual desktop fix"
    #https://bugs.winehq.org/show_bug.cgi?id=48419
    #https://bugs.winehq.org/show_bug.cgi?id=48462
    patch -Np1 < ../patches/game-patches/rawinput_v_desktop.patch
 
#    echo "gta v key input fix"
#    only needed if esync is disabled
#    patch -Np1 < ../patches/game-patches/gta_v_keyboard_input.patch
    
    echo "Denuvo anti-cheat DOOM Eternal hotfix"
    patch -Np1 < ../patches/game-patches/gofman_dac.patch

# Currently applied but not working:

#  TODO: Add game-specific check
    echo "mk11 patch"
    patch -Np1 < ../patches/game-patches/mk11.patch

#   The game uses CEG which does not work in proton.    
    echo "blackops 2 fix"
    patch -Np1 < ../patches/game-patches/blackops_2_fix.patch

    ### END GAME PATCH SECTION ###
    
    #PROTON
    
    echo "clock monotonic"
    patch -Np1 < ../patches/proton-5.9/proton-use_clock_monotonic.patch

    echo "amd ags"
    patch -Np1 < ../patches/proton-5.9/proton-amd_ags.patch
    
    echo "bypass compositor"
    patch -Np1 < ../patches/proton-5.9/proton-FS_bypass_compositor.patch

    echo "applying winevulkan childwindow"
    patch -Np1 < ../patches/wine-hotfixes/winevulkan-childwindow.patch

    #WINE FSYNC
    echo "applying fsync patches"
    patch -Np1 < ../patches/proton-5.9/proton-fsync_staging.patch
    patch -Np1 < ../patches/proton-5.9/proton-fsync-spincounts.patch

    echo "fix for Dark Souls III, Sekiro, Nier" 
    patch -Np1 < ../patches/game-patches/nier-nofshack.patch

    echo "LAA"
    patch -Np1 < ../patches/proton-5.9/proton-LAA_staging.patch

    echo "proton overlay mouse lag fix"
    patch -Np1 < ../patches/proton/proton-staging-rawinput-overlay.patch
    
    echo "proton force mouse fullscreen grab"
    patch -Np1 < ../patches/proton/proton-nofshack-force-fullscreen-grab-mouse.patch
    
    echo "proton alt-tab hotfixes"
    patch -Np1 < ../patches/proton/proton-alt-tab-focus-hotfixes.patch

    echo "steamclient swap"
    patch -Np1 < ../patches/proton-5.9/proton-steamclient_swap.patch

#    disabled for now -- was breaking Catherine Classic in 5.9
#    echo "audio patch test"
#    patch -Np1 < ../patches/proton/proton-xaudio2_stop_engine.patch

    echo "protonify"
    patch -Np1 < ../patches/proton-5.9/proton-protonify_staging.patch

    echo "protonify-audio"
    patch -Np1 < ../patches/proton-5.9/proton-pa-staging.patch
    
    echo "steam bits"
    patch -Np1 < ../patches/proton-5.9/proton-steam-bits.patch

    echo "seccomp"
    patch -Np1 < ../patches/proton-5.9/proton-seccomp-envvar.patch

    echo "SDL Joystick"
    patch -Np1 < ../patches/proton-5.9/proton-sdl_joy.patch
    patch -Np1 < ../patches/proton-5.9/proton-sdl_joy_2.patch
    
    echo "proton gamepad additions"
    patch -Np1 < ../patches/proton-5.9/proton-gamepad-additions.patch

    echo "Valve VR patches"
    patch -Np1 < ../patches/proton-5.9/proton-vr.patch

#    echo "FS Hack integer scaling"
#    patch -Np1 < ../patches/proton/proton_fs_hack_integer_scaling.patch
    
    echo "proton winevulkan"
    patch -Np1 < ../patches/proton-5.9/proton-winevulkan-nofshack.patch
    
    echo "msvcrt overrides"
    patch -Np1 < ../patches/proton-5.9/proton-msvcrt_nativebuiltin.patch

    echo "valve registry entries"
    patch -Np1 < ../patches/proton-5.9/proton-apply_LargeAddressAware_fix_for_Bayonetta.patch
    patch -Np1 < ../patches/proton-5.9/proton-Set_amd_ags_x64_to_built_in_for_Wolfenstein_2.patch
    
    echo "set prefix win10"
    patch -Np1 < ../patches/proton-5.9/proton-win10_default.patch

    echo "dxvk_config"
    patch -Np1 < ../patches/proton-5.9/proton-dxvk_config.patch

    echo "hide wine prefix update"
    patch -Np1 < ../patches/proton-5.9/proton-hide_wine_prefix_update_window.patch

    echo "applying WoW vkd3d wine patches"
    patch -Np1 < ../patches/wine-hotfixes/vkd3d/D3D12SerializeVersionedRootSignature.patch
    patch -Np1 < ../patches/wine-hotfixes/vkd3d/D3D12CreateVersionedRootSignatureDeserializer.patch
            
    echo "guy's media foundation alpha patches"
    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/media_foundation_alpha.patch
    
    echo "proton-specific manual mfplat dll register patch"
    patch -Np1 < ../patches/wine-hotfixes/media_foundation/proton_mediafoundation_dllreg.patch
    
    #WINE CUSTOM PATCHES
    #add your own custom patch lines below
    
    echo "Paul's Diablo 1 menu fix"
    patch -Np1 < ../patches/game-patches/diablo_1_menu.patch
    

#    echo "Remi's memory performance fixes"    
#    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/ntdll-Use_the_free_ranges_in_find_reserved_free_area.patch
#    patch -Np1 < ../patches/wine-hotfixes/backports-for-5.9/makedep-Align_PE_sections_so_they_can_be_mmapped.patch
    


    ./dlls/winevulkan/make_vulkan
    ./tools/make_requests
    autoreconf -f

    #end
