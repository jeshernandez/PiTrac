package com.verdanttechs.jakarta.ee9.model;

import lombok.Data;

@Data

public class WebServerConfig {
    private String tomcatShareDirectory;
    private String resultBallExposureCandidates;
    private String resultSpinBall1Image;
    private String resultSpinBall2Image;
    private String resultBallRotatedByBestAngles;
    private String errorExposuresImage;
    private String ballSearchAreaImage;
    private int refreshTimeSeconds;


    
}