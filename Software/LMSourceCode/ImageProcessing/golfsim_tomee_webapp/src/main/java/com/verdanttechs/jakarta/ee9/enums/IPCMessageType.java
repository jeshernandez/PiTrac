package com.verdanttechs.jakarta.ee9.enums;

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