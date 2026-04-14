# Installing macOS Tahoe from Bare Metal

This guide covers how to create a bootable USB installer and perform a fresh, "bare metal" installation of macOS. 

> [!NOTE]
> **macOS Tahoe (26.x)** is the final version of macOS to support Intel-based Macs, check the [compatible list](https://support.apple.com/en-ca/122867). Newer versions (macOS 27+) require Apple Silicon.

### 1. Compatibility & Connection Requirements
* **Wired Connectivity Required:** During a bare-metal install, the Mac must be connected to the internet via **Ethernet (using a dongle if necessary)**. The installer needs a stable, wired connection to fetch firmware updates and device-specific "BridgeOS" information that Wi-Fi may fail to provide during the pre-boot environment.
* **Compatible Intel Macs:** MacBook Pro 16-inch (2019), Mac Pro (2019), MacBook Pro 13-inch (2020, 4-port), and iMac 27-inch (2020).
* **Compatible Apple Silicon:** All models M1 through M5.

### 2. Prepare the Installer (Terminal)

#### Step A: Download the Latest Version
Instead of a static version number, always fetch the highest available release for longevity. First, check the list:
```bash
softwareupdate --list-full-installers
```
Identify the highest version number (e.g., **26.4.1**) and download it:
```bash
# Replace [version] with the highest number from the list above
softwareupdate --fetch-full-installer --full-installer-version [version]
```

#### Step B: Create the Bootable Media
1. Plug in a USB drive (32GB+).
2. Format it in Disk Utility as **Mac OS Extended (Journaled)** and name it `Untitled`.
3. Run the creation command:
```bash
sudo /Applications/Install\ macOS\ Tahoe.app/Contents/Resources/createinstallmedia --volume /Volumes/Untitled
```

### 3. Perform the Installation

1.  **Connect the Ethernet cable/dongle** to the Mac being serviced.
2.  **Boot to the Installer:**
    * **Apple Silicon:** Press and hold **Power** until "Loading startup options" appears. Select the USB.
    * **Intel:** Press and hold **Option (⌥)** immediately after chime. Select the USB.
3.  **Wipe the internal Drive:** Open **Disk Utility**, select the internal SSD, and click **Erase**. 
    * **Format:** APFS. 
    * **Scheme:** GUID Partition Map.
4.  **Install:** Quit Disk Utility and select **Install macOS Tahoe**. Follow the prompts. The wired connection will handle the necessary firmware handshakes automatically.

To round out the "bare metal" experience, this section documents the critical handshakes and setup steps that occur once the installer is running. This is where the **wired connection** becomes essential for bypassing activation and firmware hurdles.

### 4. Critical Post-Wipe Actions

Once you have erased the internal drive and initiated the installer, the Mac will go through several specific stages.

#### A. Activation Lock & Firmware Verification
Because you are on a wired connection, the Mac will automatically reach out to Apple’s servers.
* **Activation Lock:** If the Mac was previously linked to an Apple ID, you will be prompted to enter the credentials or the "Device Key."
* **Firmware Updates:** For Intel Macs (specifically those with the T2 chip), the installer will verify the **System BridgeOS**. If the wired connection is active, this happens silently in the background. If disconnected, the install will fail with a "Required firmware update could not be installed" error.

#### B. The "Two-Stage" Reboot
The Mac will reboot at least twice during the process. 
* **Stage 1:** The installer copies files from the USB to the internal SSD.
* **Stage 2:** The Mac boots from the *internal* drive to finish the configuration. 
* **Note:** Do **not** unplug the USB or the Ethernet cable until you see the "Hello" setup screen.

### 5. Setup Assistant Configuration

Once the "Hello" screen appears, follow these steps to ensure a clean, "bare metal" state:

1.  **Network:** It will detect your Ethernet connection automatically. You can skip Wi-Fi setup entirely at this stage.
2.  **Migration Assistant:** Since this is a scratch install, select **"Not Now"** at the bottom left to avoid pulling in legacy configurations.
3.  **Account Creation:** * Create your primary Admin account.
    * **Pro-Tip:** If this is a machine you intend to "image" or hand off to another user, do not sign into an Apple ID yet. Choose **"Set Up Later"** to keep the OS clean.
    * Do not enable FileVault yet, this is part of the process to ensure that the Recovery Key is stored in 1Password
    * **Analytics:** Disable "Share with Developers" to reduce background telemetry on older Intel hardware.

### 6. Verification Post-Install

Once you reach the desktop, run one final check to ensure the firmware and OS are perfectly synced via the terminal:

```bash
softwareupdate -ia --verbose
```
