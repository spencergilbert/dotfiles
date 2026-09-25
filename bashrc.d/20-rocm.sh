# ROCm 10 (amdrocm-* RPMs) ships no profile script and does not put
# /opt/rocm/bin on PATH, so add it here. Guarded for non-ROCm hosts.
if [ -d /opt/rocm/bin ]; then
    export ROCM_PATH=/opt/rocm
    export HIP_PATH="$ROCM_PATH"
    export PATH="$ROCM_PATH/bin:$PATH"
fi
