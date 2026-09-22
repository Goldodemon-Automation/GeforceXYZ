fn main() {
    // Delay-loading Media Foundation is an MSVC link feature. MinGW's ld has no
    // /DELAYLOAD or delayimp, so it must stay out of GNU toolchain links.
    if std::env::var("CARGO_CFG_TARGET_OS").as_deref() == Ok("windows")
        && std::env::var("CARGO_CFG_TARGET_ENV").as_deref() == Ok("msvc")
    {
        println!("cargo:rustc-link-arg=/DELAYLOAD:mfplat.dll");
        println!("cargo:rustc-link-lib=delayimp");
    }

    if std::env::var("CARGO_CFG_TARGET_OS").as_deref() == Ok("linux")
        && std::env::var_os("CARGO_FEATURE_LINUX_FFMPEG_BUNDLED").is_some()
    {
        // OpenH264 is compiled from C++ sources. The production Linux binary
        // carries that runtime and GCC's unwinder after the native media
        // archives that reference them.
        println!("cargo:rustc-link-lib=static=stdc++");
        println!("cargo:rustc-link-lib=static=gcc");
        println!("cargo:rustc-link-lib=static=gcc_eh");
        println!("cargo:rustc-link-arg=-Wl,-Bstatic");
        println!("cargo:rustc-link-arg=-lstdc++");
        println!("cargo:rustc-link-arg=-lgcc");
        println!("cargo:rustc-link-arg=-lgcc_eh");
        println!("cargo:rustc-link-arg=-Wl,-Bdynamic");
        println!("cargo:rustc-link-arg=-lm");
        println!("cargo:rustc-link-arg=-lc");
    }
}
