#!/usr/bin/env python3

import logging
import os
import subprocess
from cros.factory.test import session
from cros.factory.test import test_case
from cros.factory.test import device_data
from cros.factory.test import test_ui
from cros.factory.device import device_utils
from cros.factory.test.i18n import _


UFS_PATH='/usr/sbin/factory_ufs'
NVME_PATH='/dev/nvme0n1'
EMMC_PATH='/sys/block/mmcblk0'



class StorageState(test_case.TestCase):

  def setUp(self):
      self.dut = device_utils.CreateDUTInterface()


  def check_nvme_cycle(self):
        cmd = ['nvme', 'smart-log', NVME_PATH]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
             logging.info('Failed to get NVMe smart log: %s', result.stderr)
        power_cycle_count = None
        power_on_hours = None
        for line in result.stdout.split('\n'):
             if 'power_cycles' in line:
                 power_cycle_count = int(line.split()[2])
             if 'power_on_hours' in line:
                 power_on_hours = int(line.split()[2])
        session.console.info('NVMe power cycle count: %s, power on hours: %s', power_cycle_count, power_on_hours)
        value = f'SSD {power_cycle_count} {power_on_hours}'
        device_data.UpdateDeviceData({'factory.device.HD1H': value})
        if power_cycle_count >= 2000:
             self.ui.SetState(_(f"SSD power cycle count: <span style='color:red'>{power_cycle_count}</span>, power on hours: <span style='color:red'>{power_on_hours}</span>"))
             self.WaitTaskEnd()
        else:
             self.PassTask()
  
  def check_ufs_cycle(self):
        cmd = [UFS_PATH, 'show']
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
             logging.info('Failed to get UFS attribute: %s', result.stderr)
             return None
        sys_path = None
        for line in result.stdout.split('\n'):
             if 'UFS BSG sys path' in line:
                 sys_path = line.split('UFS BSG sys path: ')[1]
                 break
        return sys_path
  
  def read_ufs_files(self, sys_path):
      files = ['life_time_estimation_a', 'life_time_estimation_b', 'eol_info']
      data = {}
      health_dir = os.path.abspath(os.path.join(sys_path, '../../health_descriptor'))
      for file in files:
          file_path = os.path.join(health_dir, file)
          try:
              with open(file_path, 'r') as f:
                  data[file] = f.read().strip()
          except Exception as e:
              logging.info('Failed to read %s: %s', file_path, e)
              data[file] = None
      value = f"UFS ltea={data['life_time_estimation_a']} lteb={data['life_time_estimation_b']} eol={data['eol_info']}"
      print(value)
      device_data.UpdateDeviceData({'factory.device.HD1H': value})
      return data
  
  def read_emmc_files(self):
      files = ['life_time','pre_eol_info']
      data = {}
      emmc_path = '/sys/block/mmcblk0/device'
      for file in files:
          file_path = os.path.join(emmc_path, file)
          try:
              with open(file_path, 'r') as f:
                  data[file] = f.read().strip()
          except Exception as e:
              logging.info('Failed to read %s: %s', file_path, e)
              data[file] = None
      value = f"eMMC life_time={data['life_time']} pre_eol_info={data['pre_eol_info']}"
      device_data.UpdateDeviceData({'factory.device.HD1H': value})
      return data
        
  def runTest(self):
      if os.path.exists(NVME_PATH):
          self.check_nvme_cycle()
      elif os.path.exists(UFS_PATH):
          self.check_ufs_cycle()
          self.read_ufs_files(self.check_ufs_cycle())
      elif os.path.exists(EMMC_PATH):
          self.read_emmc_files()
      else:
          session.console.info('No supported storage device found.')
          self.FailTask()
