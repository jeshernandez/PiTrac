package com.verdanttechs.jakarta.ee9.types;

public enum IPCMessageType {
  kUnknown,
  kRequestForCamera2Image,
  kCamera2Image,
  kRequestForCamera2TestStillImage,
  kResults,
  kShutdown,
  kCamera2ReturnPreImage,
  kControlMessage;
}
