package com.verdanttechs.jakarta.ee9.util;

import com.verdanttechs.jakarta.ee9.enums.GsClubType;
import com.verdanttechs.jakarta.ee9.enums.GsIPCResultType;
import jakarta.servlet.http.HttpServletRequest;
import org.msgpack.core.MessagePack;
import org.msgpack.core.MessageUnpacker;
import org.msgpack.value.ArrayValue;
import org.msgpack.value.Value;

import java.util.Vector;

public class GsIPCResult {


    public int carry_meters_ = 0;
    public float speed_mpers_ = 0;
    public float launch_angle_deg_ = 0;
    public float side_angle_deg_ = 0;
    public int back_spin_rpm_ = 0;
    public int side_spin_rpm_ = 0;     // Negative is left (counter-clockwise from above ball)
    public int confidence_ = 0;
    public GsClubType club_type_ = GsClubType.kNotSelected;
    public GsIPCResultType result_type_ = GsIPCResultType.kUnknown;
    public String message_ = "No message set";
    public Vector<String> log_messages_ = new Vector<String>(20, 2);

    public static int MetersToYards(int meters) {
        return (int) ((3.281 / 3.0) * meters);
    }

    public static float MetersPerSecondToMPH(float speed_mpers) {
        return (float) (speed_mpers * 2.23694);
    }

    public static String FormatClubType(GsClubType club_type) {

        String s;

        switch (club_type) {
            case kDriver: {
                s = "Driver";
                break;
            }

            case kIron: {
                s = "Iron";
                break;
            }

            case kPutter: {
                s = "Putter";
                break;
            }

            default:
            case kNotSelected: {
                s = "Not selected";
                break;
            }
        }
        return s;
    }

    public String Format(HttpServletRequest request) {

        int carry_yards = MetersToYards(carry_meters_);
        float speed_mph = MetersPerSecondToMPH(speed_mpers_);

        String result_type = FormatResultType(result_type_);

        String carry_yards_str;
        String speed_mph_str;
        String launch_angle_deg_str;
        String side_angle_deg_str;
        String back_spin_rpm_str;
        String side_spin_rpm_str;
        String confidence_str;
        String club_str = "";
        String result_type_str;
        String message_str;
        String log_messages_str = "";
        String log_messages_console_str = "";
        String control_buttons_str;

        // System.out.println("Format called.");

        if (club_type_ != GsClubType.kNotSelected) {
            club_str = FormatClubType(club_type_);
        }

        if (Math.abs(speed_mph) > 0.001) {
            carry_yards_str = "--";  // TBD  - Not implemented yet.   String.valueOf(carry_yards) + " yards";

            if (club_type_ != GsClubType.kPutter) {
                int speed_mph_int = (int) speed_mph;
                speed_mph_str = String.format("%.1f", speed_mph) + " mph";
                launch_angle_deg_str = String.format("%.1f", launch_angle_deg_) + "&deg";
            } else {
                speed_mph_str = String.format("%.2f", speed_mph) + " mph";
                launch_angle_deg_str = "--";
            }
            side_angle_deg_str = String.format("%.1f", side_angle_deg_) + "&deg";

            // Spin doesn't really make sense for a putter
            if (club_type_ != GsClubType.kPutter && Math.abs(back_spin_rpm_) > 0.001) {
                if (back_spin_rpm_ == 0.0 && side_spin_rpm_ == 0.0) {
                    back_spin_rpm_str = "N/A";
                    side_spin_rpm_str = "N/A";

                }
                if (Math.abs(back_spin_rpm_) < 100000) {
                    back_spin_rpm_str = String.valueOf(back_spin_rpm_) + " rpm";
                    String side_spin_direction = "L ";
                    if (side_spin_rpm_ < 0.0) {
                        side_spin_direction = "R ";
                    }
                    side_spin_rpm_str = side_spin_direction + String.valueOf(side_spin_rpm_) + " rpm";
                } else {
                    back_spin_rpm_str = "err-out of range";
                    side_spin_rpm_str = "err-out of range";
                }
            } else {
                // System.out.println("Received back_spin_rpm_ = 0.");
                back_spin_rpm_str = "--";
                side_spin_rpm_str = "--";
            }
            confidence_str = String.valueOf(confidence_) + " rpm";
        } else {
            carry_yards_str = "--";
            speed_mph_str = "--";
            launch_angle_deg_str = "--";
            side_angle_deg_str = "--";
            back_spin_rpm_str = "--";
            side_spin_rpm_str = "--";
            result_type_str = "--";
            confidence_str = "--";
            message_str = "--";
        }

        // System.out.println("Format about to convert result_type.");

        if (result_type != "") {
            result_type_str = String.valueOf(result_type);
        } else {
            result_type_str = "--";
        }

        if (message_ != "") {
            message_str = String.valueOf(message_);
        } else {
            message_str = "--";
        }

        if (log_messages_.size() > 0) {
            log_messages_str = "<log-text>";
            log_messages_str += "<br><br>       <b>Log Messages:</b> <br>";

            for (int i = 0; i < log_messages_.size(); i++) {
                log_messages_str += log_messages_.elementAt(i) + "<br>";
                log_messages_console_str += log_messages_.elementAt(i) + "\n";
            }

            log_messages_str += "<\\log-text>";
        } else {
            log_messages_str = "--";
        }

        carry_yards_str += "  (" + club_str + ")";

        request.setAttribute("carry_yards", carry_yards_str);
        request.setAttribute("speed_mph", speed_mph_str);
        request.setAttribute("launch_angle_deg", launch_angle_deg_str);
        request.setAttribute("side_angle_deg", side_angle_deg_str);
        request.setAttribute("back_spin_rpm", back_spin_rpm_str);
        request.setAttribute("side_spin_rpm", side_spin_rpm_str);
        request.setAttribute("confidence", confidence_str);
        request.setAttribute("result_type", result_type_str);
        request.setAttribute("message", message_str);
        request.setAttribute("log_messages", log_messages_str);

        String s = "Carry: " + carry_yards_str + " yards." +
                "              Speed: " + speed_mph_str + " mph.<br>" +
                "       Launch Angle: " + launch_angle_deg_str + " degrees." +
                "         Side Angle: " + side_angle_deg_str + " degrees.<br>" +
                "          Back Spin: " + back_spin_rpm_str + " rpm." +
                "          Side Spin: " + side_spin_rpm_str + " rpm.<br>" +
                "         Confidence: " + confidence_str + " (0-10).<br>" +
                "          Club Type: " + club_type_ + " 0-Unselected, 1-Driver, 2-Iron, 3-Putter\n" +
                "        Result Type: " + result_type_str + "<br>" +
                "            Message: " + message_str;

        if (log_messages_.size() > 0) {
            s += "       Log Messages:\n" + log_messages_console_str;
        }

        // Set the GUI top color to be white as a default.  Special cases follow
        request.setAttribute("ball_ready_color", "\"item1 grid-item-text-center-white\"");

        // System.out.println("Checking for Ball placed");

        if (result_type_ == GsIPCResultType.kBallPlacedAndReadyForHit) {
            System.out.println("Ball placed - setting ball_ready_color to 'item1 grid-item-text-center-green'");
            request.setAttribute("ball_ready_color", "\"item1 grid-item-text-center-green\"");
        }

        if (result_type_ == GsIPCResultType.kWaitingForSimulatorArmed) {
            System.out.println("kWaitingForSimulatorArmed - setting ball_ready_color to 'item1 grid-item-text-center-yellow'");
            request.setAttribute("ball_ready_color", "\"item1 grid-item-text-center-yellow\"");
        }

        // If the result is a hit, then include IMG images
        // Even if it's an error, we might still find the images (if they
        // exist) to be useful
        if (result_type_ == GsIPCResultType.kHit) {
            String images_string = "";

            if (club_type_ == GsClubType.kDriver) {
                images_string += "<img src=\"" + kWebServerTomcatShareDirectory + "/" + kWebServerResultSpinBall1Image + "\" alt=\"1st Ball Image\" />" +
                        "<img src=\"" + kWebServerTomcatShareDirectory + "/" + kWebServerResultSpinBall2Image + "\" alt=\"2nd Ball Image\" />" +
                        "<img src=\"" + kWebServerTomcatShareDirectory + "/" + kWebServerResultBallRotatedByBestAngles + "\" alt=\"Ball1 Rotated by determined angles image\" />";
            }

            images_string += "<img src=\"" + kWebServerTomcatShareDirectory + "/" + kWebServerResultBallExposureCandidates + "\" alt=\"Identified Exposures Image\" width = \"720\" heigth=\"544\" />";

            request.setAttribute("images", images_string);
        } else if (result_type_ == GsIPCResultType.kError) {
            request.setAttribute("images", "<img src=\"" + kWebServerTomcatShareDirectory + "/" + kWebServerResultBallExposureCandidates + "\" alt=\"Identified Exposures Image\" width = \"720\" heigth=\"544\" />" +
                    "<img src=\"" + kWebServerTomcatShareDirectory + "/" + kWebServerErrorExposuresImage + "\" alt=\"Camera2 Image\" width = \"720\" heigth=\"544\" />");
        } else if (result_type_ == GsIPCResultType.kWaitingForBallToAppear) {
            // Make sure the user can see what the monitor is seeing, especially if the user may have placed the ball outside the ball search area
            request.setAttribute("images", "<img src=\"" + kWebServerTomcatShareDirectory + "/" + kWebServerBallSearchAreaImage + "\" alt=\"Ball Search Area\" width = \"360\" heigth=\"272\" />");
        }


        // control_buttons_str = "<button onclick=\"console.log('Putter Button Pressed.'); callPutterMode();\">Putter</button>";
        String driver_button_color_string;
        String putter_button_color_string;
        if (club_type_ != GsClubType.kPutter) {
            driver_button_color_string = "#04AA6D";  // Green
            putter_button_color_string = "#e7e7e7";  // Gray
        } else {
            driver_button_color_string = "#e7e7e7";  // Gray
            putter_button_color_string = "#04AA6D";  // Green
        }

        control_buttons_str = "<style> ";
        control_buttons_str += " input[value=\"Putter\"] { background-color: " + putter_button_color_string + ";} ";
        control_buttons_str += " input[value=\"Driver\"] { background-color: " + driver_button_color_string + ";} ";
        control_buttons_str += " </style>";

        control_buttons_str += "<form action=\"monitor\" method=\"post\"> " +
                "<input type=\"submit\" name=\"driver\" value=\"Driver\" background-color: " + driver_button_color_string + "; style=\" font-family: 'Arial'; font-size:30px;\" />  " +
                "<input type=\"submit\" name=\"putter\" value=\"Putter\" background-color: " + putter_button_color_string + "; style=\" font-family: 'Arial'; font-size:30px;\" />  " +
                "<input type=\"submit\" name=\"P1\" value=\"P1\"  background-color: #04AA6D; style=\"font-family: 'Arial'; font-size:30px;\" />" +
                "<input type=\"submit\" name=\"P2\" value=\"P2\" style=\"font-family: 'Arial'; font-size:30px;\" />" +
                "<input type=\"submit\" name=\"P3\" value=\"P3\" style=\"font-family: 'Arial'; font-size:30px;\" />" +
                "<input type=\"submit\" name=\"P4\" value=\"P4\" style=\"font-family: 'Arial'; font-size:30px;\" />" +
                " </form>";
        request.setAttribute("control_buttons", control_buttons_str);


        return s;
    }

    public String FormatResultType(GsIPCResultType t) {
        String s = "NA";

        switch (t) {
            case kWaitingForBallToAppear: {
                s = "Waiting for ball to appear in view frame";
                break;
            }

            case kWaitingForSimulatorArmed: {
                s = "Waiting for the simulator to be armed";
                break;
            }

            case kInitializing: {
                s = "Initializing launch monitor.";
                break;
            }

            case kPausingForBallStabilization: {
                s = "Pausing for the placed ball to stabilize";
                break;
            }

            case kMultipleBallsPresent: {
                s = "Muliple balls present";
                break;
            }

            case kBallPlacedAndReadyForHit: {
                s = "Ball placed and ready to be hit";
                break;
            }

            case kHit: {
                s = "Ball hit";
                break;
            }

            case kError: {
                s = "Error";
                break;
            }

            case kUnknown: {
                s = "Unknown";
                break;
            }

            case kCalibrationResults: {
                s = "CalibrationResults";
                break;
            }

            default: {
                s = "N/A (" + String.valueOf(t.ordinal()) + ")";
                break;
            }
        }

        return s;
    }

    public boolean unpack(byte[] byteData) {

        MessageUnpacker unpacker = MessagePack.newDefaultUnpacker(byteData);

        // System.out.println("Unpacking Results Message");
        try {
            // Assume the unpacked data has a single, array value
            Value arrayValue = unpacker.unpackValue();

            ArrayValue a = arrayValue.asArrayValue();

            // TBD - Move to the IPCResult class
            carry_meters_ = a.get(0).asIntegerValue().toInt();

            switch (a.get(1).getValueType()) {
                case INTEGER:
                    speed_mpers_ = a.get(1).asIntegerValue().toInt();
                    break;

                case FLOAT:
                    speed_mpers_ = a.get(1).asFloatValue().toFloat();
                    break;

                default:
                    System.out.println("Could not convert speed_mpers_ value");
                    break;
            }

            // System.out.println("Unpacked speed_mpers_");

            // The following overcomes apparent bug in msgpack where floats that don't have fractional parts
            // come across as integers
            switch (a.get(2).getValueType()) {
                case INTEGER:
                    launch_angle_deg_ = a.get(2).asIntegerValue().toInt();
                    break;

                case FLOAT:
                    launch_angle_deg_ = a.get(2).asFloatValue().toFloat();
                    break;

                default:
                    System.out.println("Could not convert launch_angle_deg_ value");
                    break;
            }

            switch (a.get(3).getValueType()) {
                case INTEGER:
                    side_angle_deg_ = a.get(3).asIntegerValue().toInt();
                    break;

                case FLOAT:
                    side_angle_deg_ = a.get(3).asFloatValue().toFloat();
                    break;

                default:
                    System.out.println("Could not convert side_angle_deg_ value");
                    break;
            }

            // System.out.println("Unpacking back_spin_rpm_.");

            back_spin_rpm_ = a.get(4).asIntegerValue().toInt();
            side_spin_rpm_ = a.get(5).asIntegerValue().toInt();
            confidence_ = a.get(6).asIntegerValue().toInt();

            // System.out.println("unpacked club type value: " + String.valueOf(a.get(7).asIntegerValue().toInt()));

            club_type_ = GsClubType.values()[a.get(7).asIntegerValue().toInt()];

            // System.out.println("unpacked club type: " + String.valueOf(club_type_));

            result_type_ = GsIPCResultType.values()[a.get(8).asIntegerValue().toInt()];

            if (!a.get(9).isNilValue()) {
                message_ = a.get(9).asStringValue().toString();
            }

            // System.out.println("Unpacking log messages.");

            if (!a.get(10).isNilValue()) {

                ArrayValue log_messages_value = a.get(10).asArrayValue();

                log_messages_.clear();
                for (int i = 0; i < log_messages_value.size(); i++) {
                    log_messages_.addElement(new String(log_messages_value.get(i).asStringValue().toString()));
                }
            }

        } catch (Exception e) {
            System.out.println("Error occurred in unpack: " + e.getMessage());
            return false;
        }

        return true;
    }

}
