package com.verdanttechs.jakarta.ee9.enums;

public enum GsIPCResultType {
        kUnknown,
        kInitializing,
        kWaitingForBallToAppear,
        kWaitingForSimulatorArmed,
        kPausingForBallStabilization,
        kMultipleBallsPresent,
        kBallPlacedAndReadyForHit,
        kHit,
        kError,
        kCalibrationResults;
    }
