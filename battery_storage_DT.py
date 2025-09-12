#!/usr/bin/env python3
import os
import subprocess
import sys

def run_cmd(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, text=True).strip()
    except subprocess.CalledProcessError:
        return None

# 1. Battery cycle count
try:
    with open("/sys/class/power_supply/BAT0/cycle_count") as f:
        cycle_count = f.read().strip()
    os.system(f'factory device-data factory.ShipBat={cycle_count}')
except Exception:
    pass

# 2. Check if factory_ufs exists
has_tool = 1 if run_cmd("which factory_ufs") else 0

# 3. Check NVMe SSD
if run_cmd("lsblk | grep nvme"):
    try:
        smart_log = run_cmd("nvme smart-log /dev/nvme0")
        power_cycles, power_on_hours, unsafe_shutdowns = None, None, None
        if smart_log:
            for line in smart_log.splitlines():
                if "power_cycles" in line:
                    power_cycles = line.split()[-1]
                elif "power_on_hours" in line:
                    power_on_hours = line.split()[-1]
                elif "unsafe_shutdowns" in line:
                    unsafe_shutdowns = line.split()[-1]

        if power_cycles is None:
            raise ValueError("power_cycles not found")

        ret = f"SSD {power_cycles} {power_on_hours} {unsafe_shutdowns}"
        os.system(f'factory device-data factory.HD1H="{ret}"')

        if int(power_cycles) >= 2000 or int(unsafe_shutdowns or 0) >= 2000:
            # 这里模拟 UI 提示 (可以替换成工厂UI工具调用)
            print(f"[UI] SSD PowerCycles={power_cycles}, UnsafeShutdowns={unsafe_shutdowns}")

        sys.exit(0)
    except Exception as e:
        os.system(f'factory device-data factory.HD1H="SSD Error: {e}"')
        sys.exit(-1)

# 4. If factory_ufs exists
if has_tool == 1:
    ufs_show = run_cmd("factory_ufs show")
    if ufs_show and "No UFS" in ufs_show:
        # eMMC
        try:
            with open("/sys/block/mmcblk0/device/life_time") as f:
                parts = f.read().split()
                a, b = parts[0], parts[1]
            with open("/sys/block/mmcblk0/device/pre_eol_info") as f:
                eol = f.read().strip()
            os.system(f'factory device-data factory.HD1H="EMMC ltea={a} lteb={b} eol={eol}"')
        except Exception:
            pass
    else:
        # UFS
        ufs_path = run_cmd("factory_ufs show | grep 'sys path' | awk '{print $NF}' | cut -d '/' -f1-5")
        if ufs_path:
            health_path = f"{ufs_path}/health_descriptor"
            try:
                with open(f"{health_path}/life_time_estimation_a") as f:
                    ltea = f.read().strip()
                with open(f"{health_path}/life_time_estimation_b") as f:
                    lteb = f.read().strip()
                with open(f"{health_path}/eol_info") as f:
                    eol = f.read().strip()
                os.system(f'factory device-data factory.HD1H="UFS ltea={ltea} lteb={lteb} eol={eol}"')
            except Exception:
                pass

# 5. If factory_ufs not found, fallback to mmc extcsd
if has_tool == 0:
    id_line = run_cmd("lsblk | grep mmcblk | grep -v - | grep -v boot | awk '{print $1}'")
    if id_line:
        ltea = run_cmd(f"mmc extcsd read /dev/{id_line} | grep 'Estimation A' | awk '{{print $NF}}'")
        lteb = run_cmd(f"mmc extcsd read /dev/{id_line} | grep 'Estimation B' | awk '{{print $NF}}'")
        eol  = run_cmd(f"mmc extcsd read /dev/{id_line} | grep 'eMMC Pre EOL' | awk '{{print $NF}}'")
        os.system(f'factory device-data factory.HD1H="EMMC ltea={ltea} lteb={lteb} eol={eol}"')
