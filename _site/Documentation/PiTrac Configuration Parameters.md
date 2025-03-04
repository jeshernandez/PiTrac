**PiTrac Configuration Parameters**

**TBD \- THIS DOCUMENT IS UNDER CONSTRUCTION**

The document explains the use and meaning of the parameters in the golf\_sim\_config.json file that holds the parameters that help control PiTrac's operation.

| Group | Config Name | Typical Value | Meaning/Notes |
| :---- | :---- | ----- | ----- |
| logging: |  |  |  |
|  | kLogIntermediateExposureImagesToFile: | 1, |  |
|  | kLogIntermediateSpinImagesToFile: | 0, |  |
|  | kLogWebserverImagesToFile: | 1, |  |
|  | kLogDiagnosticImagesToUniqueFiles: | 0, |  |
|  | kLinuxBaseImageLoggingDir: | /home/PiTracUserName/LM\_Shares/Images/, | Directory where all output (e.g,. diagnostic) images will be placed.  It’s best to put it in a directory on the Pi 1 that is shared out so that the images are easily accessible from a Windows/Mac development environment. |
|  | kPCBaseImageLoggingDir: | M:\\\\Dev\\\\PiTrac\\\\Software\\\\LMSourceCode\\\\Images\\\\ | When running on a PC, this replaces the role of kLinuxBaseImageLoggingDir, above.  Both parameters usually point to the same place, but from (different Linux/PC) perspectives. |
|  |  |  |  |
| modes: |  |  |  |
|  | kStartInPuttingMode: | 0 | If 0, PiTrac assumes Driving (non-putting) mode. |
| }, |  |  |  |
|  |  |  |  |
| ball\_identification: |  |  |  |
|  | kStrobedBallsCannyLower: | 33, |  |
|  | kStrobedBallsCannyUpper: | 90, |  |
|  | kStrobedBallsMinHoughReturnCircles: | 8, |  |
|  | kStrobedBallsMaxHoughReturnCircles: | 20, |  |
|  |  |  |  |
|  | NOTE-The following are NOT for externally-strobed (comparison-test): | 0, |  |
|  | kStrobedBallsMinParam2: | 18, |  |
|  | kStrobedBallsMaxParam2: | 140, |  |
|  | kStrobedBallsStartingParam2: | 60, |  |
|  | kStrobedBallsParam2Increment: | 4, |  |
|  | kStrobedBallsCurrentParam1: | 130, |  |
|  | kStrobedBallsHoughDpParam1: | 1.7, |  |
|  | kStrobedBallsPreCannyBlurSize: | 3, |  |
|  | kStrobedBallsPreHoughBlurSize: | 13, |  |
|  |  |  |  |
|  | kStrobedBallsUseAltHoughAlgorithm: | 1, |  |
|  |  |  |  |
|  | kStrobedBallsAltCannyLower: | 35, |  |
|  | kStrobedBallsAltCannyUpper: | 80, |  |
|  | kStrobedBallsAltPreCannyBlurSize: | 11, |  |
|  | kStrobedBallsAltPreHoughBlurSize HAS TO BE ODD: | 0, |  |
|  | kStrobedBallsAltPreHoughBlurSize: | 11, |  |
|  | kStrobedBallsAltMinParam2: | 0.5, |  |
|  | kStrobedBallsAltMaxParam2: | 1.0, |  |
|  | kStrobedBallsAltStartingParam2: | 0.65, |  |
|  | kStrobedBallsAltParam2Increment: | 0.05, |  |
|  | kStrobedBallsAltCurrentParam1: | 130.0, |  |
|  | kStrobedBallsAltHoughDpParam1: | 0.8, |  |
|  |  |  |  |
|  | kPuttingBallMinParam2: | 0.8, |  |
|  | kPuttingBallMaxParam2: | 1.0, |  |
|  | kPuttingBallStartingParam2: | 0.9, |  |
|  | kPuttingBallParam2Increment: | 0.03, |  |
|  | kPuttingBallCurrentParam1: | 300.0, |  |
|  | kPuttingMinHoughReturnCircles: | 6, |  |
|  | kPuttingMaxHoughReturnCircles: | 25, |  |
|  | kPuttingHoughDpParam1: | 1.5, |  |
|  | kPuttingPreHoughBlurSize: | 9, |  |
|  |  |  |  |
|  | kPlacedBallCannyLower: | 55, |  |
|  | kPlacedBallCannyUpper: | 110, |  |
|  | kPlacedBallMinParam2: | 0.8, |  |
|  | kPlacedBallMaxParam2: | 1.0, |  |
|  | kPlacedBallStartingParam2: | 0.9, |  |
|  | kPlacedBallParam2Increment: | 0.03, |  |
|  | kPlacedBallCurrentParam1: | 300.0, |  |
|  | kPlacedPreCannyBlurSize: | 5, |  |
|  | kPlacedPreHoughBlurSize: | 13, |  |
|  | kPlacedMinHoughReturnCircles: | 1, |  |
|  | kPlacedMaxHoughReturnCircles: | 4, |  |
|  | kPlacedBallHoughDpParam1: | 1.5, |  |
|  | kPlacedBallUseLargestBall: | 0, |  |
|  |  |  |  |
|  | kUseBestCircleRefinement: | 0, |  |
|  | kUseBestCircleLargestCircle: | 0, |  |
|  |  |  |  |
|  | kBestCircleCannyLower: | 55, |  |
|  | kBestCircleCannyUpper: | 110, |  |
|  | kBestCirclePreCannyBlurSize: | 5, |  |
|  | kBestCirclePreHoughBlurSize: | 13, |  |
|  | kBestCircleParam1: | 300, |  |
|  | kBestCircleParam2: | 0.65, |  |
|  | kBestCircleHoughDpParam1: | 1.5, |  |
|  |  |  |  |
|  | kBestCircleIdentificationMinRadiusRatio: | 0.90, |  |
|  | kBestCircleIdentificationMaxRadiusRatio: | 1.2, |  |
|  |  |  |  |
|  | kUseDynamicRadiiAdjustment: | 0, |  |
|  | kNumberRadiiToAverageForDynamicAdjustment: | 2, |  |
|  |  |  |  |
|  | kStrobedNarrowingRadiiMinRatio: | 0.7, |  |
|  | kStrobedNarrowingRadiiMaxRatio: | 1.3, |  |
|  | kStrobedNarrowingRadiiDpParam: | 1.5, |  |
|  | kStrobedNarrowingRadiiParam2: | 0.8, |  |
|  | kPlacedNarrowingRadiiMinRatio: | 0.9, |  |
|  | kPlacedNarrowingRadiiMaxRatio: | 1.1, |  |
|  | kPlacedNarrowingStartingParam2: | 0.9, |  |
|  | kPlacedNarrowingParam1: | 300, |  |
|  | kPlacedNarrowingRadiiDpParam: | 1.5 |  |
| }, |  |  |  |
|  |  |  |  |
| ball\_position: | { |  |  |
|  | kExpectedBallPositionXcm: | \-54, |  |
|  | kExpectedBallPositionYcm: | \-28, |  |
|  | kExpectedBallPositionZcm: | 56, |  |
|  | kExpectedBallRadiusPixelsAt40cm: | 87, |  |
|  | kMinMovedBallRadiusRatio: | 0.6, |  |
|  | kMaxMovedBallRadiusRatio: | 1.5, |  |
|  | kMinRadiusRatio: | 0.8, |  |
|  | kMaxRadiusRatio: | 1.7, |  |
|  | kBallAreaMaskRadiusRatio: | 7.0, |  |
|  | kMinBallRadiusPixelsForProximityWarning: | 160 |  |
| }, |  |  |  |
|  |  |  |  |
| ball\_exposure\_selection: | { |  |  |
|  |  |  |  |
|  | kNumberHighQualityBallsToRetain: | 2, |  |
|  | kMaximumOffTrajectoryDistance: | 8, |  |
|  | kMaxStrobedBallColorDifferenceRelaxed: | 70000, |  |
|  | kMaxPuttingBallColorDifferenceRelaxed: | 40000, |  |
|  | kMaxStrobedBallColorDifferenceStrict: | 30000, |  |
|  | kBallProximityMarginPercentRelaxed: | 65, |  |
|  | kBallProximityMarginPercentStrict: | 15, |  |
|  | kColorDifferenceRgbPostMultiplierForDarker: | 4.0, |  |
|  | kColorDifferenceRgbPostMultiplierForLighter: | 1.0, |  |
|  | kColorDifferenceStdPostMultiplierForDarker: | 3.0, |  |
|  | kColorDifferenceStdPostMultiplierForLighter: | 5.0, |  |
|  | kMaxDistanceFromTrajectory: | 30.0, |  |
|  | kClosestBallPairEdgeBackoffPixels: | 200, |  |
|  | kEARLIERMaxIntermediateBallRadiusChangePercent: | 12.0, |  |
|  | kMaxRadiusDifferencePercentageFromBest: | 35.0, |  |
|  | kMaxIntermediateBallRadiusChangePercent: | 5.0, |  |
|  | kMaxPuttingIntermediateBallRadiusChangePercent: | 8.0, |  |
|  | kMaxOverlappedBallRadiusChangeRatio: | 1.3, |  |
|  | kUsePreImageSubtraction: | 0, |  |
|  | kPreImageWeightingOverall: | 0.0, |  |
|  | kPreImageWeightingBlue: | 1.05, |  |
|  | kPreImageWeightingGreen: | 1.2, |  |
|  | kPreImageWeightingRed: | 1.0, |  |
|  | kMaxBallsToRetain: | 30, |  |
|  | kUnlikelyAngleMinimumDistancePixels: | 40, |  |
|  | kMaxQualityExposureLaunchAngle: | 35, |  |
|  | kMinQualityExposureLaunchAngle: | \-5, |  |
|  | kMaxPuttingQualityExposureLaunchAngle: | 8, |  |
|  | kMinPuttingQualityExposureLaunchAngle: | \-5, |  |
|  | kNumberAngleCheckExposures: | 4 |  |
| }, |  |  |  |
|  |  |  |  |
| spin\_analysis: | { |  |  |
|  |  |  |  |
|  | kGaborMaxWhitePercent: | 45, |  |
|  | kGaborMinWhitePercent: | 39, |  |
|  | kCoarseXRotationDegreesIncrement: | 3, |  |
|  | kCoarseXRotationDegreesStart: | \-33, |  |
|  | kCoarseXRrotationDegreesEnd: | 33, |  |
|  | kCoarseYRotationDegreesIncrement: | 5, |  |
|  | kCoarseYRotationDegreesStart: | \-5, |  |
|  | kCoarseYRotationDegreesEnd: | 5, |  |
|  | kCoarseZRotationDegreesIncrement: | 4, |  |
|  | kCoarseZRotationDegreesStart: | \-20, |  |
|  | kCoarseZRotationDegreesEnd: | 110 |  |
| }, |  |  |  |
|  |  |  |  |
| ipc\_interface: | { |  |  |
|  | kWebActiveMQHostAddress: | tcp://10.0.0.41:61616, |  |
|  | kMaxCam2ImageReceivedTimeMs: | 40000 |  |
| }, |  |  |  |
|  |  |  |  |
| user\_interface: | { |  |  |
|  | kWebServerTomcatShareDirectory: | Images, | The shared directory into which the Pi 1 system will place images that the Pi 2’s Tomcat webserver-based user interface will display along with shot result information.  Typically, this directory is served off the Pi 1 and mounted on Pi 2 via, e.g., Samba.   This directory will be cleared every time a new shot is made. The key distinction between this parameter and the kWebServerShareDirectory is that the TomcatShare is relative to the /opt/tomee/webapps/golfsim directory, whereas the kWebServerShareDirectory is an absolute path from the perspective of the Pi 1 system.  They are otherwise assumed to point to the same place. |
|  | kWebServerShareDirectory: | /home/PiTracUserName/LM\_Shares/Images, |  |
|  | kWebServerResultBallExposureCandidates: | ball\_exposure\_candidates, |  |
|  | kWebServerResultSpinBall1Image: | spin\_ball\_1\_gray\_image1, |  |
|  | kWebServerResultSpinBall2Image: | spin\_ball\_2\_gray\_image1, |  |
|  | kWebServerResultBallRotatedByBestAngles: | ball1\_rotated\_by\_best\_angles, |  |
|  | kWebServerCamera2Image: | log\_cam2\_last\_strobed\_img, |  |
|  | kWebServerLastTeedBallImage: | log\_ball\_final\_found\_ball\_img, |  |
|  | kWebServerErrorExposuresImage: | log\_cam2\_last\_strobed\_img, |  |
|  | kWebServerBallSearchAreaImage: | log\_cam1\_search\_area\_img, |  |
|  | kRefreshTimeSeconds: | 3 |  |
| }, |  |  |  |
|  |  |  |  |
| physical\_constants: | { |  |  |
|  | kBallRadiusMeters: | 0.021335 |  |
| }, |  |  |  |
|  |  |  |  |
| strobing: | { |  |  |
|  | number\_bits\_for\_fast\_on\_pulse\_: | 6, |  |
|  | number\_bits\_for\_slow\_on\_pulse\_: | 8, |  |
|  | kBaudRateForFastPulses: | 115200, |  |
|  | kBaudRateForSlowPulses: | 115200, |  |
|  | kStrobePulseVectorDriver: | \[ 0.175, 0.7, 1.4, 2.45, 1.26, 2.8, 2.1, 3.15, 3.85, 3.85, 1.4, 3.5, 0 \], |  |
|  | kPuttingStrobeDelayMs: | 50, |  |
|  | SLOWkStrobePulseVectorDriver: | \[ 0.25, 1, 2, 3.5, 1.8, 4, 3, 4.5, 5.5, 5.5, 2, 5.0, 0 \], |  |
|  | kStrobePulseVectorPutter: | \[ 2.5, 5.0, 8.0, 10.5, 8.5, 21.0, 21.0, 21.0, 21.0, 21.0, 21.0, 21.0, 0 \], |  |
|  | kDynamicFollowOnPulseVectorPutter: | \[ 444.0 \], |  |
|  | kLastPulsePutterRepeats: | 0, |  |
|  | OLDkStrobePulseVectorDriver: | \[ 0.25, 1, 2, 3.5, 4.5, 4, 4.5, 6.7, 0 \], |  |
|  | OKkStrobePulseVectorPutter: | \[ 5.0, 10.0, 16.0, 21.0, 17.0, 42.0, 42.0, 42.0, 42.0, 42.0, 42.0, 42.0, 0 \], |  |
|  | kStandardBallSpeedSlowdownPercentage: | 0.5, |  |
|  | kPracticeBallSpeedSlowdownPercentage: | 4.0, |  |
|  | kPuttingBallSpeedSlowdownPercentage: | 5.2, |  |
|  | kBaudRatePulseMultiplier: | 1.0, |  |
|  | kCameraRequiresFlushPulse: | 0 |  |
| }, |  |  |  |
|  |  |  |  |
| image\_capture: | { |  |  |
|  | kMaxWatchingCropWidth: | 96, |  |
|  | kMaxWatchingCropHeight: | 88 |  |
| }, |  |  |  |
|  |  |  |  |
| cameras: | { |  |  |
|  | kCameraMotionDetectSettings: | ./assets/motion\_detect.json, |  |
|  | kCamera1FocalLength: | 6.33, |  |
|  | kCamera2FocalLength: | 6.11, |  |
|  | comment \- kCamera1Gain \= 6 and kCamera1Contrast=1.3 is good for practice ball. For regular ball, 3 and 1.5: | 0, |  |
|  | kCamera1Gain: | 1.0, |  |
|  | kCamera1Contrast: | 1.0, |  |
|  | kCamera2Gain: | 3.0, |  |
|  | kCamera2ComparisonGain: | 0.8, |  |
|  | kCamera2CalibrateOrLocationGain: | 1.0, |  |
|  | kCamera2Contrast: | 1.2, |  |
|  | kCamera2PuttingGain: | 1.5, |  |
|  | kCamera2PuttingContrast: | 1.2, |  |
|  | kCamera1StillShutterTimeuS: | 40000, |  |
|  | kCamera2StillShutterTimeuS: | 15000, |  |
|  | kCamera1PositionsFromOriginMeters: | \[ 0.60, 0.275, 0.56 \], |  |
|  | kCamera2PositionsFromOriginMeters: | \[ 0.0, \-0.051, 0.55 \], |  |
|  | kCamera2OffsetFromCamera1OriginMeters: | \[ 0.03, \-0.19, 0.0 \], |  |
|  | kCamera1Angles: | \[ 46.97, \-18.33 \], |  |
|  | kCamera2Angles: | \[ 0, 6.77 \], |  |
|  | kCamera1XOffsetForTilt: | 0, |  |
|  | kCamera1YOffsetForTilt: | 0, |  |
|  | kCamera2XOffsetForTilt: | 0, |  |
|  | kCamera2YOffsetForTilt: | 0, |  |
|  | kCamera1CalibrationMatrix: | \[ |  |
|  |  | \[ 1.825268110451985876e+03, 0.000000000000000000e+00, 6.560920394665909043e+02 \], |  |
|  |  | \[ 0.000000000000000000e+00, 1.827901989005196810e+03, 5.319678162262430305e+02 \], |  |
|  |  | \[ 0.000000000000000000e+00, 0.000000000000000000e+00, 1.000000000000000000e+00 \] |  |
|  | \], |  |  |
|  | kCamera1DistortionVector: | \[ \-0.546987, | 0.432329, |
|  | kCamera2CalibrationMatrix: | \[ |  |
|  |  | \[ 1.836374063510859514e+03, 0.000000000000000000e+00, 7.506562375932951454e+02 \], |  |
|  |  | \[ 0.000000000000000000e+00, 1.842554330618142558e+03, 5.583207746468583537e+02 \], |  |
|  |  | \[ 0.000000000000000000e+00, 0.000000000000000000e+00, 1.000000000000000000e+00 \] |  |
|  | \], |  |  |
|  | kCamera2DistortionVector: | \[ \-0.504763, 0.173410, 0.001554, 0.000916, 0.355220 \], |  |
|  | kNumInitialCamera2PrimingPulses: | 12, |  |
|  | kPauseBeforeCamera2PrimingPulsesMs: | 2000, |  |
|  | kPauseBeforeSendingPreImageTriggerMs: | 2000, |  |
|  | kPauseAfterSendingPreImageTriggerMs: | 2000, |  |
|  | kPauseBeforeSendingImageFlushMs: | 300, |  |
|  | kPauseBeforeSendingFinalImageTriggerMs: | 2000, |  |
|  | kPauseBeforeSendingLastPrimingPulse: | 1500 |  |
|  |  |  |  |
| }, |  |  |  |
|  |  |  |  |
| calibration: | { |  |  |
|  | kCamera1CalibrationDistanceToBall: | 0.87, |  |
|  | kCamera2CalibrationDistanceToBall: | 0.55 |  |
| }, |  |  |  |
|  |  |  |  |
| golf\_simulator\_interfaces: | { |  |  |
|  | kLaunchMonitorIdString: | PiTrac LM 0.1, |  |
|  | kSkipSpinCalculation: | 0, |  |
|  | DISABLED-GSPro: | { |  |
|  |  | kGSProConnectAddress: | 10.0.0.47, |
|  |  | kGSProConnectPort: | 921 |
|  | }, |  |  |
|  | DISABLED-E6: | { |  |
|  |  | kE6ConnectAddress: | 10.0.0.10, |
|  |  | kE6ConnectPort: | 2483, |
|  |  | kE6InterMessageDelayMs: | 50 |
|  | } |  |  |
| }, |  |  |  |
|  |  |  |  |
| testing: | { |  |  |
|  | kTwoImageTestTeedBallImage: | gs\_log\_img\_\_log\_ball\_final\_found\_ball\_img.png, |  |
|  | kTwoImageTestStrobedImage: | log\_cam2\_last\_strobed\_img.png, |  |
|  |  |  |  |
|  | kExternallyStrobedEnvNumber\_bits\_for\_fast\_on\_pulse\_: | 5, |  |
|  |  |  |  |
|  | kExternallyStrobedEnvFilterImage: | 1, |  |
|  | kExternallyStrobedEnvBottomIgnoreHeight: | 110, |  |
|  | kExternallyStrobedEnvFilterHsvLowerH: | 14, |  |
|  | kExternallyStrobedEnvFilterHsvUpperH: | 48, |  |
|  | kExternallyStrobedEnvFilterHsvLowerS: | 26, |  |
|  | kExternallyStrobedEnvFilterHsvUpperS: | 255, |  |
|  | kExternallyStrobedEnvFilterHsvLowerV: | 114, |  |
|  | kExternallyStrobedEnvFilterHsvUpperV: | 255, |  |
|  | kExternallyStrobedEnvHoughLineIntersections: | 58, |  |
|  | kExternallyStrobedEnvLinesAngleLower: | 190, |  |
|  | kExternallyStrobedEnvLinesAngleUpper: | 290, |  |
|  | kExternallyStrobedEnvMaximumHoughLineGap: | 7, |  |
|  | kExternallyStrobedEnvMinimumHoughLineLength: | 23, |  |
|  |  |  |  |
|  | kExternallyStrobedBestCircleCannyLower: | 35, |  |
|  | kExternallyStrobedBestCircleCannyUpper: | 70, |  |
|  | kExternallyStrobedBestCirclePreCannyBlurSize: | 1, |  |
|  | kExternallyStrobedBestCirclePreHoughBlurSize: | 11, |  |
|  | kExternallyStrobedBestCircleParam1: | 130, |  |
|  | kExternallyStrobedBestCircleParam2: | 70, |  |
|  | kExternallyStrobedBestCircleHoughDpParam1: | 1.3, |  |
|  |  |  |  |
|  | The following control the BestCircle algorithm when used with the ALT\_GRADIENT mode: | 55, |  |
|  | kExternallyStrobedALTBestCircleCannyLower: | 55, |  |
|  | kExternallyStrobedALTBestCircleCannyUpper: | 110, |  |
|  | kExternallyStrobedALTBestCirclePreCannyBlurSize: | 5, |  |
|  | kExternallyStrobedALTBestCirclePreHoughBlurSize: | 15, |  |
|  | kExternallyStrobedALTBestCircleParam1: | 100, |  |
|  | kExternallyStrobedALTBestCircleParam2: | 0.9, |  |
|  | kExternallyStrobedALTBestCircleHoughDpParam1: | 1.5, |  |
|  |  |  |  |
|  | kExternallyStrobedEnvCannyLower: | 33, |  |
|  | kExternallyStrobedEnvCannyUpper: | 66, |  |
|  | kExternallyStrobedEnvBallCurrentParam1: | 140.0, |  |
|  | kExternallyStrobedEnvBallMinParam2: | 40, |  |
|  | kExternallyStrobedEnvBallMaxParam2: | 120, |  |
|  | kExternallyStrobedEnvBallStartingParam2: | 83, |  |
|  | kExternallyStrobedEnvBallParam2Increment: | 5, |  |
|  | kExternallyStrobedEnvBallNarrowingParam2: | 0.7, |  |
|  | kExternallyStrobedEnvBallNarrowingDpParam: | 0.9, |  |
|  | kExternallyStrobedEnvBallNarrowingPreCannyBlurSize: | 1, |  |
|  | kExternallyStrobedEnvBallNarrowingPreHoughBlurSize: | 9, |  |
|  | kExternallyStrobedEnvMinHoughReturnCircles: | 6, |  |
|  | kExternallyStrobedEnvMaxHoughReturnCircles: | 20, |  |
|  | kExternallyStrobedEnvPreCannyBlurSize: | 1, |  |
|  | kExternallyStrobedEnvPreHoughBlurSize: | 11, |  |
|  | kExternallyStrobedEnvHoughDpParam1: | 1.3, |  |
|  | kExternallyStrobedEnvMinimumSearchRadius: | 55, |  |
|  | kExternallyStrobedEnvMaximumSearchRadius: | 95, |  |
|  |  |  |  |
|  | kInterShotInjectionPauseSeconds: | 22, |  |
|  |  |  |  |
|  | test\_shots\_to\_inject: | { |  |
|  |  | 1: | { |
|  |  |  | Speed: |
|  |  |  | BackSpin: |
|  |  |  | SideSpin: |
|  |  |  | HLA: |
|  |  |  | VLA: |
|  |  | }, |  |
|  |  | 2: | { |
|  |  |  | Speed: |
|  |  |  | BackSpin: |
|  |  |  | SideSpin: |
|  |  |  | HLA: |
|  |  |  | VLA: |
|  |  | }, |  |
|  |  | 3: | { |
|  |  |  | Speed: |
|  |  |  | BackSpin: |
|  |  |  | SideSpin: |
|  |  |  | HLA: |
|  |  |  | VLA: |
|  |  | }, |  |
|  |  | 4: | { |
|  |  |  | Speed: |
|  |  |  | BackSpin: |
|  |  |  | SideSpin: |
|  |  |  | HLA: |
|  |  |  | VLA: |
|  |  | }, |  |
|  |  | 5: | { |
|  |  |  | Speed: |
|  |  |  | BackSpin: |
|  |  |  | SideSpin: |
|  |  |  | HLA: |
|  |  |  | VLA: |
|  |  | }, |  |
|  |  | 6: | { |
|  |  |  | Speed: |
|  |  |  | BackSpin: |
|  |  |  | SideSpin: |
|  |  |  | HLA: |
|  |  |  | VLA: |
|  |  | }, |  |
|  |  | 7: | { |
|  |  |  | Speed: |
|  |  |  | BackSpin: |
|  |  |  | SideSpin: |
|  |  |  | HLA: |
|  |  |  | VLA: |
|  |  | } |  |
|  | }, |  |  |
|  | OTHER test\_shots\_to\_inject: | { |  |
|  |  | 2: | { |
|  |  |  | Speed: |
|  |  |  | BackSpin: |
|  |  |  | SideSpin: |
|  |  |  | HLA: |
|  |  |  | VLA: |
|  |  | }, |  |
|  |  | 3: | { |
|  |  |  | Speed: |
|  |  |  | BackSpin: |
|  |  |  | SideSpin: |
|  |  |  | HLA: |
|  |  |  | VLA: |
|  |  | }, |  |
|  |  | 4: | { |
|  |  |  | Speed: |
|  |  |  | BackSpin: |
|  |  |  | SideSpin: |
|  |  |  | HLA: |
|  |  |  | VLA: |
|  |  | } |  |
|  | } |  |  |
| } |  |  |  |

