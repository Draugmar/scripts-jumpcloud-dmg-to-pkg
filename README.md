# scripts-jumpcloud-dmg-to-pkg

Software Provisioning Script for macOS
Objective

This script is designed to facilitate the provisioning of software on macOS machines using JumpCloud. JumpCloud's software distribution feature supports only .pkg files, while software distributions are commonly available in .dmg format. This script automates the conversion of .dmg files to .pkg format, allowing seamless software provisioning through JumpCloud.
Script Explanation

The script performs the following steps:

    Mounts the provided .dmg file to a temporary volume.
    Converts the mounted .dmg file to .pkg format using the pkgbuild command.
    Checks the conversion status. If successful, it offers an option to add the software to a CSV file that tracks the installed software.
    If the conversion fails, it attempts to convert the .dmg file using the hdiutil convert command.
    If the conversion is successful after using hdiutil convert, it mounts the converted .dmg file and performs the conversion to .pkg format again.
    Offers an option to add the software to the CSV file if the conversion is successful.
    Detaches the mounted .dmg file or converted .dmg file.
    Cleans up temporary files.

TO_DO

In case the downloaded file is in a format other than .dmg, such as .zip, .tar.gz, or .rar, the script should be extended to handle the extraction of the .dmg file from these archives. Once the .dmg file is extracted, the script can continue with the regular conversion process.

Please note that this TO_DO task requires additional development and is not currently implemented in the provided script.
Software List

The software_list.csv file contains examples of software entries that can be customized to suit your needs. It provides a structure to follow when adding software to the list. The CSV file includes the following columns:

    Software Name: The name of the software to be provisioned.
    Download URL: The URL from where the software can be downloaded in .dmg format.

To add new software entries, follow the format of the existing entries in the CSV file, ensuring that each entry has a unique combination of software name and download URL.
