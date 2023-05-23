#!/bin/bash

# Destination folder for .pkg files
DEST_FOLDER="./apps/"
# Temporary folder
TMP_FOLDER="./tmp/"
# CSV file
CSV_FILE="./software_list.csv"
# Debug mode
DEBUG_MODE=false

# Function to clean temporary files
clean_temp_files() {
  rm -rf "$TMP_FOLDER"
}

# Function to display an error message and exit
show_error_message() {
  echo "Error: $1" >&2
  clean_temp_files
  exit 1
}

# Function to display a warning message
show_warning_message() {
  echo "Warning: $1"
}

# Function to display a debug message
show_debug_message() {
  if [ "$DEBUG_MODE" = true ]; then
    echo "Debug: $1"
  fi
}

# Function to check the existence of an entry in the CSV file
entry_exists_in_csv() {
  local csv_file="$1"
  local software_name="$2"
  local download_url="$3"
  local existing_entry=$(awk -F ',' -v name="$software_name" -v url="$download_url" '$1 == name && $2 == url {print $0}' "$csv_file")
  if [ -n "$existing_entry" ]; then
    return 0
  else
    return 1
  fi
}

# Check if the URL and software name were provided as arguments
if [ $# -lt 2 ]; then
  # If no arguments were provided, check the CSV file
  if [ -f "$CSV_FILE" ]; then
    # Read the CSV file and print the list of software
    echo "Available software list:"
    awk -F ',' 'NR>1 {print $2}' "$CSV_FILE"
    exit 0
  else
    show_error_message "URL and software name must be provided as arguments."
  fi
fi

# Check if debug mode is enabled
if [ "$1" = "--debug" ]; then
  DEBUG_MODE=true
  shift
fi

# Download URL
DOWNLOAD_URL="$1"

# Software name
SOFTWARE_NAME="$2"

# Create temporary folder if it doesn't exist
mkdir -p "$TMP_FOLDER" || show_error_message "Failed to create temporary folder $TMP_FOLDER."

# Create destination folder if it doesn't exist
mkdir -p "$DEST_FOLDER" || show_error_message "Failed to create destination folder $DEST_FOLDER."

# Download the file to the temporary folder
echo "Downloading $DOWNLOAD_URL..."
retry_count=3
while [ $retry_count -gt 0 ]; do
  curl -o "$TMP_FOLDER$SOFTWARE_NAME.dmg" -JL "$DOWNLOAD_URL" && break
  echo "Download error. Retrying..."
  ((retry_count--))
done
[ $retry_count -eq 0 ] && show_error_message "Failed to download file from $DOWNLOAD_URL."

# Rest of the code...

# Verify the integrity of the .dmg file
echo "Verifying .dmg file integrity..."
hdiutil verify "$TMP_FOLDER$SOFTWARE_NAME.dmg" >/dev/null 2>&1
verify_status=$?

if [ $verify_status -ne 0 ]; then
  show_error_message "The downloaded .dmg file is either damaged or not valid."
fi

# Mount the .dmg file and get the volume name
show_debug_message "Mounting $SOFTWARE_NAME.dmg..."
MOUNT_OUTPUT=$(hdiutil attach -nobrowse "$TMP_FOLDER$SOFTWARE_NAME.dmg" | awk -F '\t' '/\/Volumes\// {print $NF; exit}') || show_error_message "Failed to mount the .dmg file."
VOLUME_NAME=$(basename "$MOUNT_OUTPUT")

# Check successful mount
if [ -z "$VOLUME_NAME" ]; then
  show_error_message "Failed to mount the .dmg file properly."
fi

show_debug_message "The .dmg file has been successfully mounted to volume $VOLUME_NAME."

# Remove existing .pkg file
if [ -f "$DEST_FOLDER$SOFTWARE_NAME.pkg" ]; then
  rm "$DEST_FOLDER$SOFTWARE_NAME.pkg"
fi

# Convert to .pkg format
echo "Converting to .pkg format..."
pkg_name="$DEST_FOLDER$SOFTWARE_NAME.pkg"
pkgbuild --root "$MOUNT_OUTPUT" --install-location "/Applications" "$pkg_name" >/dev/null 2>&1
conversion_status=$?

# Check conversion status
if [ $conversion_status -eq 0 ]; then
  echo "Conversion to .pkg format was successful."

  # Check if the software already exists in the CSV file
  if [ -f "$CSV_FILE" ]; then
    if entry_exists_in_csv "$CSV_FILE" "$SOFTWARE_NAME" "$DOWNLOAD_URL"; then
      show_warning_message "The software already exists in the CSV file."
      exit 0
    fi
  fi

  # Ask if the software should be added to the CSV file
  read -r -p "Do you want to add it to the CSV file? (Y/N): " response
  if [ "$response" = "Y" ] || [ "$response" = "y" ]; then
    # Add to CSV file
    cp "$CSV_FILE" "$TMP_FOLDER"
    echo "$SOFTWARE_NAME,$DOWNLOAD_URL" >> "$TMP_FOLDER$CSV_FILE"
    sort -t',' -k1,1 -o "$TMP_FOLDER$CSV_FILE" "$TMP_FOLDER$CSV_FILE"
    mv "$TMP_FOLDER$CSV_FILE" "$CSV_FILE"
    echo "The software has been added to the CSV file and sorted alphabetically."

    # Show the updated software list
    echo "Updated software list:"
    awk -F ',' 'NR>1 {print $1","$2}' "$CSV_FILE" | sort -t',' -k1,1
  fi

# Check if debug mode is enabled
if [ "$DEBUG_MODE" = true ]; then
  echo "Conversion details:"
  cat "$TMP_FOLDER$SOFTWARE_NAME_conversion_log.txt"
fi

else
  # If conversion fails, try using the "hdiutil convert" command
  echo "Error: Failed to convert to .pkg format."
  echo "Retrying conversion with hdiutil convert..."

  converted_dmg="$TMP_FOLDER$SOFTWARE_NAME-converted.dmg"
  hdiutil convert "$TMP_FOLDER$SOFTWARE_NAME.dmg" -format UDTO -o "$converted_dmg" >/dev/null 2>&1
  conversion_status=$?

  if [ $conversion_status -eq 0 ]; then
    MOUNT_OUTPUT=$(hdiutil attach -nobrowse "$converted_dmg" | grep -oE '/Volumes/[^[:space:]]+' | tail -1)
    VOLUME_NAME=$(basename "$MOUNT_OUTPUT")

    # Check successful mount
    if [ -z "$VOLUME_NAME" ]; then
      show_error_message "Failed to mount the converted .dmg file properly."
    fi

    show_debug_message "The converted .dmg file has been successfully mounted to volume $VOLUME_NAME."

    # Perform conversion again
    pkgbuild --root "$MOUNT_OUTPUT" --install-location "/Applications" "$pkg_name" >/dev/null 2>&1
    conversion_status=$?

    if [ $conversion_status -eq 0 ]; then
      echo "Conversion to .pkg format was successful."

      # Check if the software already exists in the CSV file
      if [ -f "$CSV_FILE" ]; then
        if entry_exists_in_csv "$CSV_FILE" "$SOFTWARE_NAME" "$DOWNLOAD_URL"; then
          show_warning_message "The software already exists in the CSV file."
          exit 0
        fi
      fi

      # Ask if the software should be added to the CSV file
      read -r -p "Do you want to add it to the CSV file? (Y/N): " response
      if [ "$response" = "Y" ] || [ "$response" = "y" ]; then
        # Add to CSV file
        cp "$CSV_FILE" "$TMP_FOLDER"
        echo "$SOFTWARE_NAME,$DOWNLOAD_URL" >> "$TMP_FOLDER$CSV_FILE"
        sort -t',' -k1,1 -o "$TMP_FOLDER$CSV_FILE" "$TMP_FOLDER$CSV_FILE"
        mv "$TMP_FOLDER$CSV_FILE" "$CSV_FILE"
        echo "The software has been added to the CSV file."
      fi

      # Detach the converted file
      hdiutil detach "$MOUNT_OUTPUT"
      rm "$converted_dmg"
    else
      echo "Error: Failed to convert to .pkg format."
      echo "Please check the .dmg file or conversion permissions."
    fi
  else
    echo "Error: Failed to convert the .dmg file."
    echo "Please check the .dmg file or conversion permissions."
  fi
fi

# Check if debug mode is enabled
if [ "$DEBUG_MODE" = true ]; then
  echo "Conversion details:"
  cat "$TMP_FOLDER$SOFTWARE_NAME_conversion_log.txt"
fi

# Detach the .dmg file
hdiutil detach "$MOUNT_OUTPUT"

# Remove temporary files
clean_temp_files
