package com.verdanttechs.jakarta.ee9.servlet;

import com.verdanttechs.jakarta.ee9.enums.GsClubType;
import com.verdanttechs.jakarta.ee9.enums.GsIPCResultType;
import com.verdanttechs.jakarta.ee9.util.GsIPCResult;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.msgpack.core.MessagePack;
import org.msgpack.core.MessageBufferPacker;


import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import jakarta.jms.Connection;
import jakarta.jms.Session;
import jakarta.jms.Destination;
import jakarta.jms.Message;
import jakarta.jms.MessageProducer;
import jakarta.jms.MessageConsumer;
import jakarta.jms.DeliveryMode;
import jakarta.jms.TextMessage;
import jakarta.jms.BytesMessage;
import jakarta.jms.JMSException;
import jakarta.jms.ExceptionListener;

import java.io.FileReader;

import com.google.gson.Gson;
import com.google.gson.JsonParser;
import com.google.gson.JsonObject;
import com.google.gson.JsonElement;

import org.apache.activemq.ActiveMQConnectionFactory;

import java.io.IOException;



@WebServlet("/monitor")
public class MonitorServlet extends HttpServlet {

    private static Logger logger = LogManager.getLogger(MonitorServlet.class);

    private static String kWebServerTomcatShareDirectory;
    private static String kWebServerResultBallExposureCandidates;
    private static String kWebServerResultSpinBall1Image;
    private static String kWebServerResultSpinBall2Image;
    private static String kWebServerResultBallRotatedByBestAngles;
    private static String kWebServerErrorExposuresImage;
    private static String kWebServerBallSearchAreaImage;


    final static int kClubChangeToPutterControlMsgType = 1;
    final static int kClubChangeToDriverControlMsgType = 2;

    public static class GsControlMessage {
        public GsClubType club_type_ = GsClubType.kNotSelected;
    }

    public static GsControlMessage control_message_;
    public static boolean producer_created = false;
    public static MessageProducer producer;
    public static Connection producer_connection;
    public static ActiveMQConnectionFactory producer_connection_factory;
    public static Session producer_session;
    public static Destination producer_destination;

    public static void SetCurrentClubType(GsClubType club) {
        logger.info("SetClubType called with club type = " + String.valueOf(club));
        System.out.println("SetClubType called with club type = " + String.valueOf(club));

        try {
            if (!producer_created) {
                producer_connection_factory = new ActiveMQConnectionFactory(kWebActiveMQHostAddress);

                producer_connection = producer_connection_factory.createConnection();
                producer_connection.start();

                producer_session = producer_connection.createSession(false, Session.AUTO_ACKNOWLEDGE);

                producer_destination = producer_session.createTopic(kGolfSimTopic);

                producer = producer_session.createProducer(producer_destination);
                producer.setDeliveryMode(DeliveryMode.NON_PERSISTENT);

                producer_created = true;
            }

            BytesMessage bytesMessage = producer_session.createBytesMessage();


            bytesMessage.setStringProperty("Message Type", "GolfSimIPCMessage");
            bytesMessage.setIntProperty("IPCMessageType", 7 /*kControlMessage*/);
            bytesMessage.setStringProperty("LM_System_ID", "LM_GUI");

            MessageBufferPacker packer = MessagePack.newDefaultBufferPacker();

            int control_msg_type = 0;

            if (club == GsClubType.kPutter) {
                control_msg_type = kClubChangeToPutterControlMsgType;
            } else if (club == GsClubType.kIron) {
                // TBD - Not yet supported
            } else if (club == GsClubType.kDriver) {
                control_msg_type = kClubChangeToDriverControlMsgType;
            }

            packer
                    .packInt(control_msg_type);

            packer.close();

            final byte[] bytes = packer.toByteArray();

            bytesMessage.writeBytes(bytes);

            System.out.println("Created BytesMessage of size = " + String.valueOf(bytes.length));

            producer.send(bytesMessage);

            // Also set the current result object to have the same club type
            current_result_.club_type_ = club;

            }
            catch (Exception e) {
                logger.error("Exception publishing changed club event", e);
            }
    }



    // File paths appear to be relative to the home of the servlet.
    // E.g., /opt/tomee/webapps/golf_sim
    private static String kGolfSimConfigJsonFilename = "golf_sim_config.json";

    private static String kGolfSimTopic = "Golf.Sim";
    // Set from environment variable or default. This can be overidden from config file later
    private static String kWebActiveMQHostAddress = System.getenv("PITRAC_MSG_BROKER_FULL_ADDRESS") != null ?
            System.getenv("PITRAC_MSG_BROKER_FULL_ADDRESS") : "tcp://127.0.0.1:61616";



    private static boolean monitorIsInitialized = false;
    private static boolean monitorIsRunning = true;
    private static boolean consumerIsCreated = false;

    private static boolean display_images = true;

    private static GsIPCResult current_result_ = new GsIPCResult();

    public static void thread(Runnable runnable, boolean daemon) {
        Thread brokerThread = new Thread(runnable);
        brokerThread.setDaemon(daemon);
        brokerThread.start();
    }


    public boolean initializeMonitor(String config_filename) {
        if (monitorIsInitialized) {
            return true;
        }

        // The config filename comes from the request, e.g., 
        // http://rsp02:8080/golfsim/monitor?config_filename="%2Fmnt%2FVerdantShare%2Fdev%2FWebShare%2Fgolf_sim_config.json"
        Gson gson = new Gson();

        // The monitor isn't up and running yet.  Initialize

        try {

            FileReader reader = new FileReader(config_filename);

            JsonElement jsonElement = JsonParser.parseReader(reader);
            JsonObject jsonObject = jsonElement.getAsJsonObject();

            JsonElement gsConfigElement = jsonObject.get("gs_config");
            JsonElement ipcInterfaceElement = gsConfigElement.getAsJsonObject().get("ipc_interface");
            JsonElement userInterfaceElement = gsConfigElement.getAsJsonObject().get("user_interface");

            String pngSuffix = new String(".png");

            JsonElement kWebServerTomcatShareDirectoryElement = userInterfaceElement.getAsJsonObject().get("kWebServerTomcatShareDirectory");
            JsonElement kWebServerResultBallExposureCandidatesElement = userInterfaceElement.getAsJsonObject().get("kWebServerResultBallExposureCandidates");
            JsonElement kWebServerResultSpinBall1ImageElement = userInterfaceElement.getAsJsonObject().get("kWebServerResultSpinBall1Image");
            JsonElement kWebServerResultSpinBall2ImageElement = userInterfaceElement.getAsJsonObject().get("kWebServerResultSpinBall2Image");
            JsonElement kWebServerResultBallRotatedByBestAnglesElement = userInterfaceElement.getAsJsonObject().get("kWebServerResultBallRotatedByBestAngles");
            JsonElement kWebServerErrorExposuresImageElement = userInterfaceElement.getAsJsonObject().get("kWebServerErrorExposuresImage");
            JsonElement kWebServerBallSearchAreaImageElement = userInterfaceElement.getAsJsonObject().get("kWebServerBallSearchAreaImage");
            JsonElement kRefreshTimeSecondsElement = userInterfaceElement.getAsJsonObject().get("kRefreshTimeSeconds");

            if (kWebActiveMQHostAddress.isEmpty()) {
                kWebActiveMQHostAddress = ipcInterfaceElement.getAsJsonObject().get("kWebActiveMQHostAddress").getAsString();
            }

            kWebServerTomcatShareDirectory = (String) kWebServerTomcatShareDirectoryElement.getAsString();
            kWebServerResultBallExposureCandidates = (String) kWebServerResultBallExposureCandidatesElement.getAsString() + pngSuffix;
            kWebServerResultSpinBall1Image = (String) kWebServerResultSpinBall1ImageElement.getAsString() + pngSuffix;
            kWebServerResultSpinBall2Image = (String) kWebServerResultSpinBall2ImageElement.getAsString() + pngSuffix;
            kWebServerResultBallRotatedByBestAngles = (String) kWebServerResultBallRotatedByBestAnglesElement.getAsString() + pngSuffix;
            kWebServerErrorExposuresImage = (String) kWebServerErrorExposuresImageElement.getAsString() + pngSuffix;
            kWebServerBallSearchAreaImage = (String) kWebServerBallSearchAreaImageElement.getAsString() + pngSuffix;
            kRefreshTimeSeconds = (int) kRefreshTimeSecondsElement.getAsInt();

        } catch (Exception e) {
            System.out.println("Failed to parse JSON config file: " + e.getMessage());
            return false;
        }
        System.out.println("Golf Sim Configuration Settings: ");
        System.out.println("  kWebActiveMQHostAddress: " + kWebActiveMQHostAddress);
        System.out.println("  kWebServerTomcatShareDirectory (NOTE - Must be setup in Tomcat's conf/server.xml): " + kWebServerTomcatShareDirectory);
        System.out.println("  kWebServerResultBallExposureCandidates " + kWebServerResultBallExposureCandidates);
        System.out.println("  kWebServerResultSpinBall1Image " + kWebServerResultSpinBall1Image);
        System.out.println("  kWebServerResultSpinBall2Image " + kWebServerResultSpinBall2Image);
        System.out.println("  kWebServerResultBallRotatedByBestAngles " + kWebServerResultBallRotatedByBestAngles);
        System.out.println("  kWebServerErrorExposuresImage " + kWebServerErrorExposuresImage);
        System.out.println("  kWebServerBallSearchAreaImage " + kWebServerBallSearchAreaImage);


        monitorIsInitialized = true;
        return true;
    }

    private static boolean haveValidHitResult = false;

    private static int kRefreshTimeSeconds = 2;
    private static int max_time_to_reset_seconds = 60;
    private static int time_since_last_reset_seconds = 0;


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("doPost called.");

        GsIPCResult ipc_result = new GsIPCResult();

        if (request.getParameter("putter") != null) {
            SetCurrentClubType(GsClubType.kPutter);
        } else if (request.getParameter("driver") != null) {
            SetCurrentClubType(GsClubType.kDriver);
        } else {
            System.out.println("doPost received unknown request parameter.");
        }


        response.addHeader("Refresh", String.valueOf(0));

        response.setContentType("text/html");

        request.getRequestDispatcher("/WEB-INF/gs_dashboard.jsp").forward(request, response);
    }

    @Override
    public void init() throws ServletException {
        super.init();

        String configFilename = getServletContext().getInitParameter("config_filename");
        if (configFilename == null) {
            throw new ServletException("Missing config_filename init parameter");
        }


        try {
            if (!consumerIsCreated) {
                ActiveMQConnectionFactory connectionFactory = new ActiveMQConnectionFactory(kWebActiveMQHostAddress);
                Connection connection = connectionFactory.createConnection();
                connection.start();

                Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
                Destination destination = session.createTopic(kGolfSimTopic);

                System.out.println("Started consumer.");
                logger.info("Starting GolfSimConsumer thread.");
                thread(new GolfSimConsumer(), false);
                consumerIsCreated = true;
            }
        } catch (Exception e) {
            throw new ServletException("Failed to initialize ActiveMQ consumer", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String configFilename = request.getParameter("config_filename");
        String displayImagesStr = request.getParameter("display_images");


        display_images = !"0".equals(displayImagesStr);

        if (!initializeMonitor(configFilename)) {
            System.err.println("Failed to initialize the monitor.");
            logger.error("Failed to initialize the monitor with config file: " + configFilename);
        }

        HttpSession httpSession = request.getSession();
        Long times = (Long) httpSession.getAttribute("times");
        if (times == null) times = 0L;
        httpSession.setAttribute("times", ++times);

        time_since_last_reset_seconds += kRefreshTimeSeconds;
        if (time_since_last_reset_seconds > max_time_to_reset_seconds) {
            time_since_last_reset_seconds = 0;
            current_result_ = new GsIPCResult();
        }

        response.addHeader("Refresh", String.valueOf(kRefreshTimeSeconds));
        response.setContentType("text/html");

        // Forward to JSP for rendering (no more writes after this)
        request.setAttribute("debugDashboard", current_result_.Format(request));
        request.getRequestDispatcher("/WEB-INF/gs_dashboard.jsp").forward(request, response);
    }

    private static class GolfSimConsumer implements Runnable, ExceptionListener {
        public void run() {

            try {

                System.out.println("GolfSimConsumer started.");
                ActiveMQConnectionFactory connectionFactory = new ActiveMQConnectionFactory(kWebActiveMQHostAddress);

                Connection connection = connectionFactory.createConnection();
                connection.start();

                // Create a Session
                Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);

                // Create the destination (Topic or Queue)
                Destination destination = session.createTopic(kGolfSimTopic);

                // Create a MessageConsumer from the Session to the Topic or Queue
                MessageConsumer consumer = session.createConsumer(destination);

                System.out.println("Waiting to receive message...");

                while (monitorIsRunning) {

                    // Wait for a message - time is in ms
                    // TBD - should we use a queue so as not to miss anything bewtwen waits?
                    Message message = consumer.receive(100);

                    if (message == null) {
                        continue;
                    } else if (message instanceof TextMessage) {
                        TextMessage textMessage = (TextMessage) message;
                        String text = textMessage.getText();
                        System.out.println("Received TextMessage: " + text);
                    } else if (message instanceof BytesMessage) {
                        BytesMessage bytesMessage = (BytesMessage) message;
                        long length = bytesMessage.getBodyLength();
                        // System.out.println("Received BytesMessage: " + String.valueOf(length) + " bytes.");

                        // We should never (currently) be getting a message this large.  Ignore it if we do.
                        if (length > 10000) {
                            continue;
                        }

                        byte[] byteData = null;
                        byteData = new byte[(int) length];
                        bytesMessage.readBytes(byteData);

                        // System.out.println("Received BytesMessage");

                        // Make sure this is a result type message, and not something like
                        // a Cam2Image
                        int gs_ipc_message_type_tag = bytesMessage.getIntProperty("IPCMessageType");

                        if (gs_ipc_message_type_tag != 4 /* kResults */) {
                            System.out.println("Received ByesMessage of IPCMessageType: " + String.valueOf(gs_ipc_message_type_tag));
                            continue;
                        }

                        // Reset the timer because we have a new message
                        time_since_last_reset_seconds = 0;

                        GsIPCResult new_result = new GsIPCResult();
                        new_result.unpack(byteData);

                        //System.out.println("Received new result message club type of: " + String.valueOf(new_result.club_type_));

                        // Always update the club type.  This new result
                        // may have been sent only to update that.
                        current_result_.club_type_ = new_result.club_type_;

                        // Only replace the current hit result (if we have one) if the ball has been re-teed up
                        if (current_result_.speed_mpers_ > 0 || current_result_.result_type_ == GsIPCResultType.kError) {
                            // We may not want to update the screen just yet if it has useful information and
                            // the incoming result record is not very interesting
                            if (new_result.speed_mpers_ <= 0 &&
                                    (new_result.result_type_ != GsIPCResultType.kBallPlacedAndReadyForHit &&
                                            new_result.result_type_ != GsIPCResultType.kInitializing &&
                                            new_result.result_type_ != GsIPCResultType.kWaitingForSimulatorArmed &&
                                            new_result.result_type_ != GsIPCResultType.kError
                                    )) {
                                // Don't replace the current result, as the user may still be looking at it
                            } else {
                                // A new ball has been teed up, so show the new status
                                current_result_.unpack(byteData);
                            }
                        } else {
                            // We don't appear to have any prior hit result data
                            current_result_.unpack(byteData);
                        }
                    } else {
                        System.out.println("Received unknown message type: " + message);
                    }
                }
                consumer.close();
                session.close();
                connection.close();

            } catch (Exception e) {
                System.out.println("Caught: " + e);
                e.printStackTrace();
            }
        }

        public synchronized void onException(JMSException ex) {
            System.out.println("JMS Exception occured.  Shutting down client.");
        }
    }


}

