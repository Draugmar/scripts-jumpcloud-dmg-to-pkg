# scripts-jumpcloud-dmg-to-pkg

## Software Provisioning Script for macOS

**Objective**

This script is designed to facilitate the provisioning of software on macOS machines using JumpCloud. JumpCloud's software distribution feature supports only .pkg files, while software distributions are commonly available in .dmg format. This script automates the conversion of .dmg files to .pkg format, allowing seamless software provisioning through JumpCloud.

**Script Explanation**

The script performs the following steps:

1. Mounts the provided .dmg file to a temporary volume.
2. Converts the mounted .dmg file to .pkg format using the pkgbuild command.
3. Checks the conversion status. If successful, it offers an option to add the software to a CSV file that tracks the installed software.
4. If the conversion fails, it attempts to convert the .dmg file using the hdiutil convert command.
5. If the conversion is successful after using hdiutil convert, it mounts the converted .dmg file and performs the conversion to .pkg format again.
6. Offers an option to add the software to the CSV file if the conversion is successful.
7. Detaches the mounted .dmg file or converted .dmg file.
8. Cleans up temporary files.

**TO_DO**

In case the downloaded file is in a format other than .dmg, such as .zip, .tar.gz, or .rar, the script should be extended to handle the extraction of the .dmg file from these archives. Once the .dmg file is extracted, the script can continue with the regular conversion process.

Please note that this TO_DO task requires additional development and is not currently implemented in the provided script.

**Software List**

The `software_list.csv` file contains examples of software entries that can be customized to suit your needs. It provides a structure to follow when adding software to the list. The CSV file includes the following columns:

- **Software Name**: The name of the software to be provisioned.
- **Download URL**: The URL from where the software can be downloaded in .dmg format.

To add new software entries, follow the format of the existing entries in the CSV file, ensuring that each entry has a unique combination of software name and download URL.

---

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

In jurisdictions that recognize copyright laws, the author or authors of this software dedicate any and all copyright interest in the software to the public domain. We make this dedication for the benefit of the public at large and to the detriment of our heirs and successors. We intend this dedication to be an overt act of relinquishment in perpetuity of all present and future rights to this software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---
