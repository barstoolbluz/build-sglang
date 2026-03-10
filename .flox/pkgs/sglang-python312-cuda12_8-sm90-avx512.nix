# SGLang 0.5.9 for NVIDIA Hopper (SM90: H100, H200) — AVX-512
# CUDA 12.8 — Requires NVIDIA driver 550+
# Custom PyTorch built from source (SM90 + AVX-512)
{ pkgs ? import <nixpkgs> {} }:
let
  nixpkgs_pinned = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/0182a361324364ae3f436a63005877674cf45efb.tar.gz";
  }) {
    config = {
      allowUnfree = true;
      cudaSupport = true;
      cudaCapabilities = [ "9.0" ];
    };
    overlays = [ (final: prev: { cudaPackages = final.cudaPackages_12_8; }) ];
  };
  inherit (nixpkgs_pinned) lib;

  # ── Variant-specific configuration ──────────────────────────────────
  smCapability = "9.0";
  variantName = "sglang-python312-cuda12_8-sm90-avx512";
  cpuISA = (import ./lib/cpu-isa.nix).avx512;
  platform = "x86_64-linux";

  # ── Custom Python package set with from-source torch ────────────────
  python312Custom = nixpkgs_pinned.python312.override {
    packageOverrides = self: super: {
      torch = import ./lib/custom-torch.nix {
        inherit lib smCapability cpuISA platform;
        torchBase = super.torch;
        cudaVersionTag = "cuda12_8";
      };
    };
  };

  cudaPackages = nixpkgs_pinned.cudaPackages;
  autoPatchelfHook = nixpkgs_pinned.autoPatchelfHook;
  stdenv = nixpkgs_pinned.stdenv;

  # ── Build custom CUDA packages ──────────────────────────────────────
  sgl-kernel = import ./lib/sgl-kernel.nix {
    python3 = python312Custom;
    inherit cudaPackages autoPatchelfHook stdenv;
    inherit (nixpkgs_pinned) numactl;
  };

  flashinferPkgs = import ./lib/flashinfer.nix {
    python3 = python312Custom;
    inherit cudaPackages autoPatchelfHook stdenv;
  };

  xgrammar = import ./lib/xgrammar.nix {
    python3 = python312Custom;
    inherit autoPatchelfHook stdenv;
  };

  # ── Compose SGLang ──────────────────────────────────────────────────
  sglang = import ./lib/sglang-pkg.nix {
    python3 = python312Custom;
    inherit sgl-kernel xgrammar;
    inherit (flashinferPkgs) flashinfer-python;
  };

in
  sglang.overrideAttrs (oldAttrs: {
    pname = variantName;
    requiredSystemFeatures = [ "big-parallel" ];
    meta = oldAttrs.meta // {
      description = "SGLang 0.5.9 for NVIDIA H100/H200 (SM90) [CUDA 12.8, custom PyTorch AVX-512]";
      platforms = [ platform ];
    };
  })
