# sgl-kernel 0.3.21 — pre-built CUDA kernel library for SGLang
# Uses autoPatchelfHook to patch ELF binaries against CUDA runtime libs.
{ python3, cudaPackages, autoPatchelfHook, stdenv, numactl }:

python3.pkgs.buildPythonPackage rec {
  pname = "sgl-kernel";
  version = "0.3.21";
  format = "wheel";

  src = builtins.fetchurl {
    url = "https://files.pythonhosted.org/packages/36/9f/f836e126002c7cfcfe35418f6cff5a63fe3f529c609b334ca4775354b4d5/sgl_kernel-0.3.21-cp310-abi3-manylinux2014_x86_64.whl";
    sha256 = "1axa0g9r5v2k1kh4xa7ryxc7r6s8yvavmqijki4ryxfdlfib7psp";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib                # libstdc++, libgcc_s
    cudaPackages.cuda_cudart        # libcudart.so.12
    cudaPackages.cuda_nvrtc         # libnvrtc.so.12
    cudaPackages.libcublas          # libcublas.so.12, libcublasLt.so.12
    python3.pkgs.torch              # libtorch.so, libc10.so, libc10_cuda.so, libtorch_{cpu,cuda}.so
    numactl                         # libnuma.so.1 (mscclpp, sm90/common_ops)
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libcuda.so.1"                  # provided by the NVIDIA driver at runtime
  ];

  propagatedBuildInputs = [
    python3.pkgs.torch
  ];

  pythonImportsCheck = [ "sgl_kernel" ];
}
