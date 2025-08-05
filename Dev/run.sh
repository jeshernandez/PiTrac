#!/bin/bash

# Ensure we are running under bash
if [ -z "$BASH_VERSION" ]; then
  echo "This script must be run with bash, not sh."
  exit 1
fi

# Install 'dialog' if not already installed (apt-get only)
install_dialog_if_missing() {
  if ! command -v dialog >/dev/null 2>&1; then
    echo "'dialog' is not installed. Installing with apt-get..."
    sudo apt-get update && sudo apt-get install -y dialog || {
      echo "Failed to install dialog. Please install manually."
      exit 1
    }
  fi
}

check_internet_connectivity() {
  if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    echo "Internet is offline. Please check connectivity."
    exit 1
  fi
  echo "Internet Validated..."
}

check_internet_connectivity
install_dialog_if_missing




# Verify installations

verify_java_installed() {
  if command -v java >/dev/null 2>&1 && command -v javac >/dev/null 2>&1; then
      echo "Java JRE and JDK is installed."
  else 
      sudo apt -y install openjdk-17-jdk openjdk-17-jre
  fi
}

verify_maven_installed() {
  if command -v mvn >/dev/null 2>&1; then
      echo "Maven (mvn) is installed."
  else
      sudo apt -y install maven
  fi
}


verify_pitrac_dependencies() {

local packages=("libraspberrypi-dev" "raspberrypi-kernel-headers" "libfmt-dev")

for pkg in "${packages[@]}"; do
  if dpkg -s "$pkg" > /dev/null 2>&1; then
      echo "$pkg is installed."
  else 
      sudo apt -y install $pkg
  fi

echo "PiTrac Dependencies installed."
done
}










i Menu configuration
BUILD="6.12.34-1"
VERSION="0.0.1"
TITLE="For Raspberry Pi OS version >= $BUILD"
HEIGHT=15
WIDTH=60
MENU_HEIGHT=10

MAIN_OPTIONS=(
  1 "Install Software"
  2 "Configuration(s)"
  3 "Validation(s)"
  4 "Calibration"
  5 "Exit"
)

INSTALL_OPTIONS=(
  1 "Active MQ Broker"
  2 "Active MQ C++ CMS"
  3 "MSGPack"
  4 "OpenCV 4-11-0"
  5 "Boost (WIP)"
  6 "LGPIO (WIP)"
  7 "Libcamera 0.5.1 & Rpicam Apps 1.5.3"
  8 "Java 17 OpenJDK"
  9 "Maven"
  10 "Tomee (WIP)"
  11 "PiTrac Dependencies (manual reboot required)"
  12 "Go Back to Main Menu"
)

handle_cancel_or_esc() {
  local exit_status=$1
  clear
  if [ $exit_status -ne 0 ]; then
    echo "Exiting.. No selection made."
    exit 0
  fi
}

show_main_menu() {
  while true; do
    main_choice=$(dialog --clear \
      --title "$TITLE" \
      --ok-label "OK" \
      --cancel-label "Exit" \
      --menu "Version $VERSION: " \
      $HEIGHT $WIDTH $MENU_HEIGHT \
      "${MAIN_OPTIONS[@]}" \
      2>&1 >/dev/tty)

    handle_cancel_or_esc $?

    case "$main_choice" in
      1) show_install_menu ;;
      2) ;;
      3) ;;
      4) ;;
      5) clear; exit 0 ;;
      *) echo "Invalid input $main_choice" ;;
    esac
  done
}

show_install_menu() {
  while true; do
    install_choice=$(dialog --clear \
      --title "PiTrac Installation Menu" \
      --menu "Select what to install:" \
      $HEIGHT $WIDTH $MENU_HEIGHT \
      "${INSTALL_OPTIONS[@]}" \
      2>&1 >/dev/tty)

    exit_code=$?
    if [ $exit_code -ne 0 ]; then
      break
    fi

    if [ "$install_choice" -eq 12 ]; then
      break
    fi

    dialog --yesno "Are you sure you want to install ${INSTALL_OPTIONS[((install_choice-1)*2+1)]}?" 7 50
    confirm_exit=$?

    clear
    if [ $confirm_exit -eq 0 ]; then
      case "$install_choice" in
        1)
          echo "Installing ActiveMQ Broker..."
          bash ./scripts/install_mq_broker.sh
          ;;
        2)
          echo "Installing ActiveMQ C++ CMS..."
          bash ./scripts/install_activemq_cpp_cms.sh
          ;;
        3)
          echo "Installing MSGPack..."
          bash ./scripts/install_msgpack.sh 
          ;;
        4) 
          echo "Installing OpenCV 4-11-0..."
          bash ./scripts/install_opencv.sh
          ;;
        5)
          echo "Installing Boost... (WIP)"
          ;;
          6) 
          echo "Installing LGPIO... (WIP)"
          ;;
          7)
          echo "Installing Libcamera & Rpicam Apps..."
          bash ./scripts/install_libcamera.sh
          ;;
          8) 
          echo "Installing Java JDK.."
          verify_java_installed
          ;;
          9) 
          echo "Install Maven.."
          verify_maven_installed
          ;;
          10)
          echo "Install Tomee.. (WIP)"
          ;;
          11)
          echo "Install PiTrac Dependencies..."
          verify_pitrac_dependencies
          ;;
          *)
          echo "Invalid selection."
          ;;
      esac
    else
      echo "Installation canceled by user."
    fi

    echo
    read -rp "Press Enter to return to the menu..."
  done
}

show_main_menu
clear
