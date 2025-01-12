package com.verdanttechs.jakarta.ee9.types;

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
    kCalibrationResults
}
