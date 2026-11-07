# WiFi Security Auditor - Flutter (Ethical & Authorized)

A Flutter-based WiFi security auditing tool that automatically scans nearby networks and performs **authorized** security testing.

> ⚠️ ETHICAL USE ONLY: This tool only scans broadcast information and tests password strength of networks you own or have written permission to test. Unauthorized access is illegal under PECA 2016 (Pakistan) and similar laws worldwide.

### Features

**Phase 1: Auto-Scan (No Input Required)**
- Automatically scans all nearby WiFi on app launch
- No SSID input needed
- Lists SSID, BSSID, Signal (dBm), Encryption
- Auto risk flagging:
    - CRITICAL: WEP, OPEN, No Encryption
    - HIGH: WPS Enabled, Default SSID (PTCL, TP-LINK)
    - LOW: WPA3

**Phase 2: Authorized Test (With Owner Consent)**
- User taps a network -> Ownership confirmation required
- 2-step consent: "I own this" + "I have written permission"
- Local password strength test (checks against top common weak passwords)
- Does NOT crack neighbor's WiFi - tests YOUR OWN password locally

**Phase 3: Professional PDF Report**
- Generates audit report with SSID, BSSID, Risk, Findings, Recommendations
- Ready to share with IT teams / clients

### Why This Matters for Security Companies?

Most WiFi tools on Play Store either:
1. Just show signal strength (no security value), or
2. Are illegal hacking tools (banned, risky)

This tool fills the gap: **Defensive security auditor** that can be legally used by IT admins, ISPs, and security firms for client audits.

### Tech Stack
- Flutter 3.x
- wifi_scan plugin (Android WifiManager)
- pdf + printing for reports
- permission_handler

### Installation

```bash
git clone https://github.com/YOUR_USERNAME/wifi-security-auditor-flutter
cd wifi-security-auditor-flutter
flutter pub get
flutter run
