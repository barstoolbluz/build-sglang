# FlashInfer 0.6.5 — three-wheel composition for FlashAttention-3
# - flashinfer-cubin:      pre-compiled CUDA binary objects (pure Python wheel)
# - flashinfer-jit-cache:  compiled CUDA extensions (needs autoPatchelf, cu128 variant)
# - flashinfer-python:     pure Python frontend, propagates cubin + jit-cache + torch
{ python3, cudaPackages, autoPatchelfHook, stdenv }:

let
  flashinfer-cubin = python3.pkgs.buildPythonPackage rec {
    pname = "flashinfer-cubin";
    version = "0.6.5";
    format = "wheel";

    src = builtins.fetchurl {
      url = "https://files.pythonhosted.org/packages/61/b4/18659537e1442cded7b10c87e4609607d6e719f9eaa5b4beadf7a3c38062/flashinfer_cubin-0.6.5-py3-none-any.whl";
      sha256 = "0f64vwcygcc403fcdalrj8aa6hfx2jr67flhhhd42byyhfgzvpnn";
    };

    pythonImportsCheck = [ "flashinfer_cubin" ];
  };

  flashinfer-jit-cache = python3.pkgs.buildPythonPackage rec {
    pname = "flashinfer-jit-cache";
    version = "0.6.5+cu128";
    format = "wheel";

    src = builtins.fetchurl {
      url = "https://github.com/flashinfer-ai/flashinfer/releases/download/v0.6.5/flashinfer_jit_cache-0.6.5+cu128-cp39-abi3-manylinux_2_28_x86_64.whl";
      sha256 = "175xcckipi4yxn2w0m3vbaxziil8qc0pp7wwswk5nw7zlsyvgf5n";
    };

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    buildInputs = [
      stdenv.cc.cc.lib                # libstdc++, libgcc_s
      cudaPackages.cuda_cudart        # libcudart.so.12
      cudaPackages.cuda_nvrtc         # libnvrtc.so.12
      cudaPackages.libcublas          # libcublas.so.12, libcublasLt.so.12
    ];

    autoPatchelfIgnoreMissingDeps = [
      "libcuda.so.1"
    ];

    propagatedBuildInputs = [
      python3.pkgs.torch
    ];

    pythonImportsCheck = [ "flashinfer_jit_cache" ];
  };

  flashinfer-python = python3.pkgs.buildPythonPackage rec {
    pname = "flashinfer-python";
    version = "0.6.5";
    format = "wheel";

    src = builtins.fetchurl {
      url = "https://files.pythonhosted.org/packages/4f/83/eea2a74700b5fcae36ee2b748db9c3554a83a3f9e2dc4f3816369c5cb653/flashinfer_python-0.6.5-py3-none-any.whl";
      sha256 = "0l59hhyxhg4vnk700bfzqqxprqxag9k2sbib0hg4308j8msqn2jh";
    };

    propagatedBuildInputs = [
      flashinfer-cubin
      flashinfer-jit-cache
      python3.pkgs.torch
      python3.pkgs.numpy
    ];

    pythonImportsCheck = [ "flashinfer" ];
  };

in {
  inherit flashinfer-python flashinfer-cubin flashinfer-jit-cache;
}
