# Recommended Hardware

This guide provides detailed hardware recommendations for running EmergencyStorage reliably on a Raspberry Pi with large external storage.

## Overview

EmergencyStorage is designed to run on a Raspberry Pi with external storage, capable of downloading and maintaining large datasets. The recommended setup prioritizes reliability, performance, and adequate storage capacity.

## Raspberry Pi

### Recommended Models

- **Raspberry Pi 5** (recommended for best I/O performance)
- **Raspberry Pi 4 Model B** (4GB+ RAM)

### Official Documentation

- Raspberry Pi 5 product page: [Raspberry Pi 5](https://www.raspberrypi.com/products/raspberry-pi-5/)
- Raspberry Pi 4 Model B product page: [Raspberry Pi 4 Model B](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/)
- General documentation: [Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/)

### Power Requirements

- **Pi 5**: [27W USB‑C Power Supply](https://www.raspberrypi.com/products/27w-power-supply/)
- **Pi 4**: [5.1V 3A USB‑C Power Supply](https://www.raspberrypi.com/products/type-c-power-supply/)

### Boot and Storage Notes

- USB mass‑storage boot (optional): [USB mass storage boot docs](https://www.raspberrypi.com/documentation/computers/configuration.html#usb-mass-storage-boot)

## External Storage (Primary Data Drive)

### Recommended Specifications

- **Capacity**: 15TB or larger
- **Type**: 3.5" SATA HDD from a reputable vendor
- **Technology**: CMR (Conventional Magnetic Recording) drives preferred for sustained writes
- **Filesystem**: Use GPT partitioning and a Linux filesystem (e.g., ext4)
- **Ventilation**: Ensure adequate ventilation for 3.5" drives

## Storage Connection Options

### Option A: USB 3.0 SATA Docking Station

Suitable for single-drive setups using 3.5" HDDs.

#### Requirements

- Native 12V/5V power supply for the dock (do not bus‑power 3.5" drives from the Pi)
- USB 3.x and UASP support for better throughput/latency

#### References

- Linux UAS overview: [USB Attached SCSI (UAS)](https://www.kernel.org/doc/html/latest/scsi/uas.html)
- Raspberry Pi USB storage/boot guidance: [Mass storage boot](https://www.raspberrypi.com/documentation/computers/configuration.html#usb-mass-storage-boot)

#### Example Vendor Documentation (non‑endorsement)

- StarTech single‑bay USB 3.0 SATA dock: [SDOCKU33** series](https://www.startech.com/en-us/hdd/sdocku33ef)

### Option B: Raspberry Pi SATA Expansion Boards/HATs

For multi‑drive or neater integration, a Pi‑compatible SATA expansion board can be used. Ensure the board provides independent power for 3.5" drives.

#### Popular Boards and Documentation (non‑endorsement)

- Geekworm 3.5" SATA board (for Pi 4): [X828 Wiki](https://wiki.geekworm.com/X828)
- Geekworm dual 2.5" SATA HAT (for Pi 4): [X829 Wiki](https://wiki.geekworm.com/X829)
- Radxa SATA HAT (for Pi 4): [SATA HAT Wiki](https://wiki.radxa.com/SATA_HAT)

#### Notes

- Many SATA HATs for Pi 4 use USB 3.x bridges internally; performance and stability depend on the bridge chipset and firmware.
- For Raspberry Pi 5, consider PCIe‑based storage via the official M.2 HAT+ (for NVMe SSDs) if your workload suits SSDs:
  - [M.2 HAT+](https://www.raspberrypi.com/documentation/computers/raspberry-pi-5.html#m-2-hat-plus)

## Cables and Cooling

### Cables

- High‑quality USB 3.x cable (short, shielded) if using a USB dock/enclosure

### Cooling

- Adequate cooling for the Raspberry Pi (heatsink + fan or active case), especially under sustained I/O

## Compatibility Tips and Best Practices

### UASP Support

- Prefer UASP‑capable docks/bridges for better performance
- Fall back to BOT (Bulk-Only Transport) if stability issues occur

### USB-SATA Bridge Quirks

- Some USB‑SATA bridges may require "quirks" to disable UAS for stability
- Consult your bridge vendor documentation and Raspberry Pi USB storage guidance

### Power Supply

- Use a reliable power source for both the Pi and the drives
- Brownouts can cause I/O errors and filesystem corruption
- Ensure power supply has adequate capacity for all connected devices

## Alternative Platforms

While this guide focuses on Raspberry Pi, EmergencyStorage can run on:
- Any Linux PC with sufficient storage
- Other single-board computers with similar specifications
- Server hardware with appropriate storage capacity

Ensure the platform meets the basic requirements:
- Linux operating system (Ubuntu, Debian, etc.)
- Python 3.6 or later
- Sufficient storage capacity for selected data sources
- Reliable network connection for initial downloads

## Storage Planning

See [Storage Requirements](STORAGE.md) for detailed information about:
- Size estimates for each data source
- What content gets downloaded
- Storage planning recommendations

---

**Related Documentation:**
- [Installation Guide](INSTALLATION.md) - Setup instructions
- [Storage Requirements](STORAGE.md) - Size estimates and planning
- [Main README](../README.md) - Project overview
