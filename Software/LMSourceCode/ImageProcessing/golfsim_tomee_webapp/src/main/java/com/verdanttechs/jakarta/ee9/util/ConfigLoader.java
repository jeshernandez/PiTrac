package com.verdanttechs.jakarta.ee9.util;


import com.google.gson.*;
import com.verdanttechs.jakarta.ee9.model.WebServerConfig;

import java.io.FileReader;

public class ConfigLoader {

    public WebServerConfig loadConfig(String configFilename) throws Exception {
        Gson gson = new Gson();
        JsonObject root = JsonParser.parseReader(new FileReader(configFilename)).getAsJsonObject();

        JsonObject userInterface = root
                .getAsJsonObject("gs_config")
                .getAsJsonObject("user_interface");

        WebServerConfig config = new WebServerConfig();
        String pngSuffix = ".png";

        config.setTomcatShareDirectory(userInterface.get("kWebServerTomcatShareDirectory").getAsString());
        config.setResultBallExposureCandidates(userInterface.get("kWebServerResultBallExposureCandidates").getAsString() + pngSuffix);
        config.setResultSpinBall1Image(userInterface.get("kWebServerResultSpinBall1Image").getAsString() + pngSuffix);
        config.setResultSpinBall2Image(userInterface.get("kWebServerResultSpinBall2Image").getAsString() + pngSuffix);
        config.setResultBallRotatedByBestAngles(userInterface.get("kWebServerResultBallRotatedByBestAngles").getAsString() + pngSuffix);
        config.setErrorExposuresImage(userInterface.get("kWebServerErrorExposuresImage").getAsString() + pngSuffix);
        config.setBallSearchAreaImage(userInterface.get("kWebServerBallSearchAreaImage").getAsString() + pngSuffix);
        config.setRefreshTimeSeconds(userInterface.get("kRefreshTimeSeconds").getAsInt());

        return config;
    }
}