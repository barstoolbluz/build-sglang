# FlashInfer 0.6.5 — three-wheel composition for FlashAttention-3
# - flashinfer-cubin:      pre-compiled CUDA binary objects (pure Python wheel)
# - flashinfer-jit-cache:  compiled CUDA extensions (needs autoPatchelf, cu128 variant)
# - flashinfer-python:     pure Python frontend, propagates cubin + jit-cache + torch
{ python3, cudaPackages, autoPatchelfHook, stdenv }:

let
  apache-tvm-ffi = python3.pkgs.buildPythonPackage rec {
    pname = "apache-tvm-ffi";
    version = "0.1.9";
    format = "wheel";

    src = builtins.fetchurl {
      url = "https://files.pythonhosted.org/packages/c6/dd/2bab4c6cd86257dbf99e93452a1af833113f8dc3e25a25579f6e4e4c8a94/apache_tvm_ffi-0.1.9-cp312-abi3-manylinux2014_x86_64.manylinux_2_17_x86_64.whl";
      sha256 = "sha256-KCQTcZNOqK8Q1QZwh7oSKevd3teywC0zoljsKpbfjEY=";
    };

    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ stdenv.cc.cc.lib ];

    propagatedBuildInputs = [ python3.pkgs.typing-extensions ];

    # Import pulls in many transitive deps; provided at runtime via sglang closure.
    pythonImportsCheck = [ ];
  };

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

    # Torch's ninja dependency installs a setup hook that hijacks buildPhase.
    # This is a pre-built wheel — disable ninja/cmake build integration.
    dontUseNinjaBuild = true;
    dontUseNinjaInstall = true;
    dontUseCmakeConfigure = true;

    propagatedBuildInputs = [
      python3.pkgs.torch
    ];

    # Import requires CUDA runtime (libcuda.so.1) — not available in build sandbox.
    pythonImportsCheck = [ ];
  };

  flashinfer-python = python3.pkgs.buildPythonPackage rec {
    pname = "flashinfer-python";
    version = "0.6.5";
    format = "wheel";

    src = builtins.fetchurl {
      url = "https://files.pythonhosted.org/packages/4f/83/eea2a74700b5fcae36ee2b748db9c3554a83a3f9e2dc4f3816369c5cb653/flashinfer_python-0.6.5-py3-none-any.whl";
      sha256 = "0l59hhyxhg4vnk700bfzqqxprqxag9k2sbib0hg4308j8msqn2jh";
    };

    # Torch's ninja dependency installs a setup hook that hijacks buildPhase.
    # This is a pre-built wheel — disable ninja/cmake build integration.
    dontUseNinjaBuild = true;
    dontUseNinjaInstall = true;
    dontUseCmakeConfigure = true;

    propagatedBuildInputs = [
      flashinfer-cubin
      flashinfer-jit-cache
      apache-tvm-ffi
      python3.pkgs.torch
      python3.pkgs.numpy
      python3.pkgs.filelock
    ];

    # Import requires CUDA runtime (libcuda.so.1) — not available in build sandbox.
    pythonImportsCheck = [ ];
  };

in {
  inherit flashinfer-python flashinfer-cubin flashinfer-jit-cache;
}
