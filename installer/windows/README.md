# Medicail Windows MSI installer (WiX)

Produces a classic Windows Installer (`.msi`) with a setup wizard that lets the
user choose the install directory (`WixUI_InstallDir`).

## Prerequisites

- Flutter SDK (Windows desktop enabled)
- Visual Studio with the “Desktop development with C++” workload
- [WiX Toolset CLI](https://wixtoolset.org/) v7 (`winget install WiXToolset.WiXCLI`)

The build script installs the WiX CLI via winget if it is missing.

## Build

From the repository root:

```powershell
.\scripts\build_windows_msi.ps1
```

Reuse an existing Flutter release build:

```powershell
.\scripts\build_windows_msi.ps1 -SkipFlutterBuild
```

English installer UI:

```powershell
.\scripts\build_windows_msi.ps1 -Culture en-US
```

Output:

```text
build\windows\msi\Medicail-<version>-x64.msi
```

## Wizard flow

1. Welcome
2. License agreement
3. Destination folder (browse / change path)
4. Ready to install
5. Progress / finish (optional launch)

Default install location: `C:\Program Files\Medicail`

## Files

| File | Role |
|---|---|
| `Package.wxs` | Product metadata, upgrade, UI wizard |
| `Folders.wxs` | Install / Start Menu / Desktop directories |
| `Components.wxs` | Flutter payload harvest + shortcuts |
| `License.rtf` | License text shown in the wizard |

## Notes

- `UpgradeCode` in `Package.wxs` must remain unchanged across releases.
- Product version is read from `pubspec.yaml` (`major.minor.patch`).
- Debug symbols (`.pdb`) are excluded from the MSI.
