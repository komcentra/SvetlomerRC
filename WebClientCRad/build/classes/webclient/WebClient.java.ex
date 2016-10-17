package webclient;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import javax.net.ssl.*;

// je nezbytne zahrnout vsechny 3 knihovny jackson-core, databind i annotations !!
// pro https: může být třeba importovat certifikáty
// "by updating the CACERTS file in the JRE_HOME/lib/security directory"

public class WebClient {

    public static void main(String[] args) {
        WebClient app = new WebClient();
//        app.retrieve ();
//        System.out.println("========================================================");
//        app.retrieveDevices ();
//        System.out.println("========================================================");
//        app.retrievePayload ();
        System.out.println("========================================================");
        app.retrieveMe ();
    }

    void retrieve() {
        try {
//            URL iurl = new URL("https://api.pripoj.me/device/get/TEST?token=Y7J3MvLLMrXCtzpiQuPgHHu7wO046Jx6");
//            URL iurl = new URL("https://api.pripoj.me/message/get/4786E6ED00350042?token=Y7J3MvLLMrXCtzpiQuPgHHu7wO046Jx6&limit=2");
            URL iurl = new URL("https://api.pripoj.me/message/get/0004A30B001B25AC?token=Y7J3MvLLMrXCtzpiQuPgHHu7wO046Jx6&limit=4");
            HttpsURLConnection uc = (HttpsURLConnection)iurl.openConnection();
            uc.connect();
            URL newurl = uc.getURL();
            System.out.println(newurl.toString());
            System.out.println();
            System.out.println(uc.getContentType());
            InputStreamReader in = new InputStreamReader((InputStream) uc.getContent());
            BufferedReader buff = new BufferedReader(in);
            String line=" ";
            while (line!=null) {
                System.out.println(line);
                line = buff.readLine();
            }
        } catch (Exception e) {
            System.out.println (e.getMessage());
        }
    }

    void retrieveDevices () {
        // viz http://www.journaldev.com/2324/jackson-json-processing-api-in-java-example-tutorial !!
        try {
            URL iurl = new URL("https://api.pripoj.me/device/get/TEST?token=Y7J3MvLLMrXCtzpiQuPgHHu7wO046Jx6");
            InputStream is = iurl.openStream();
            // převeď stream na byte[]
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            while (true) {
                int r = is.read(buffer);
                if (r == -1) break;
                out.write(buffer, 0, r);
            }
            byte[] jsonData = out.toByteArray();
            // Jackson
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode rootNode = objectMapper.readTree(jsonData);
            JsonNode metaNode  = rootNode.path("_meta");
            JsonNode statNode  = metaNode.path("status");
            System.out.println("Status  = "+statNode.asText());
            if (statNode.asText().equals ("SUCCESS")) {
                System.out.println("Počet = "+metaNode.path("count").asText());
                JsonNode recoNode = rootNode.path("records");
		if (recoNode.isArray()) {
                    for (JsonNode node : recoNode) {
                        System.out.println("Popis = "+node.path("description").asText()+" "+node.path("model").asText());
                        System.out.println("devEUI = "+node.path("devEUI").asText());
                    }
                }
            }
        } catch (Exception e) {
            System.out.println (e.getMessage());
        }
    }

    void retrievePayload () {
        try {
            URL iurl = new URL("https://api.pripoj.me/message/get/4786E6ED00350042?token=Y7J3MvLLMrXCtzpiQuPgHHu7wO046Jx6&limit=3");
            InputStream is = iurl.openStream();
            // převeď stream na byte[]
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            while (true) {
                int r = is.read(buffer);
                if (r == -1) break;
                out.write(buffer, 0, r);
            }
            byte[] jsonData = out.toByteArray();
            String load;
            // Jackson
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode rootNode = objectMapper.readTree(jsonData);
            JsonNode metaNode  = rootNode.path("_meta");
            JsonNode statNode  = metaNode.path("status");
            System.out.println("Status  = "+statNode.asText());
            if (statNode.asText().equals ("SUCCESS")) {
                System.out.println("Počet = "+metaNode.path("count").asText());
                JsonNode recoNode = rootNode.path("records");
		if (recoNode.isArray()) {
                    for (JsonNode node : recoNode) {
                        System.out.println("Time = "+node.path("createdAt").asText());
                        System.out.println("Payload = "+node.path("payloadHex").asText());
                        load = node.path("payloadHex").asText();
                        Integer tmp = 256* Integer.valueOf(load.substring(4, 6),16)+Integer.valueOf(load.substring(2, 4),16);
                        Double temp = ((175.72*tmp)/65536)-46.85;
                        temp = Math.round(temp*100)/100.0;
                        System.out.println("Teplota = "+temp);
                    }
                }
            }
        } catch (IOException | NumberFormatException e) {
            System.out.println (e.getMessage());
        }
    }

    void retrieveMe () {
        try {
            URL iurl = new URL("https://api.pripoj.me/message/get/0004A30B00195511?token=Y7J3MvLLMrXCtzpiQuPgHHu7wO046Jx6&limit=3");
            InputStream is = iurl.openStream();
            // převeď stream na byte[]
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            while (true) {
                int r = is.read(buffer);
                if (r == -1) break;
                out.write(buffer, 0, r);
            }
            byte[] jsonData = out.toByteArray();
            Integer osvit, batt;
            // Jackson
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode rootNode = objectMapper.readTree(jsonData);
            JsonNode metaNode  = rootNode.path("_meta");
            JsonNode statNode  = metaNode.path("status");
            System.out.println("Status  = "+statNode.asText());
            if (statNode.asText().equals ("SUCCESS")) {
                System.out.println("Počet = "+metaNode.path("count").asText());
                JsonNode recoNode = rootNode.path("records");
		if (recoNode.isArray()) {
                    for (JsonNode node : recoNode) {
                        System.out.println("Time   = "+node.path("createdAt").asText());
                        System.out.println("Port   = "+node.path("fPort").asText());
                        System.out.println("P-load = "+node.path("payloadHex").asText());
                        String payload = node.path("payloadHex").asText();
                        System.out.println("Lat    = "+node.path("lrrLAT").asText());
                        System.out.println("Lon    = "+node.path("lrrLON").asText());
                        if (payload.length()==8){
                            if (payload.substring(0,2).equals("55")) {
                                osvit= Integer.parseInt(payload.substring(2,5));
                                batt = Integer.parseInt(payload.substring(5,8));
                                double battr = (batt-100);
                                battr = battr*2*5.1/899;   //uprav referenci !!
                                System.out.println("Osvit   "+osvit);
                                System.out.printf ("Baterie %.2f V%n", battr);
                            }
                        }
                        System.out.println("* * *");
                    }
                }
            }
        } catch (IOException | NumberFormatException e) {
            System.out.println (e.getMessage());
        }
    }
}

/*
TEST:
{"_meta":{"status":"SUCCESS","count":2},
"records":[
{"devEUI":"4786E6ED00350042","projectId":"TEST","description":"Testovaci teplotni cidlo","model":"RHF1S001","vendor":"Rising HF"},
{"devEUI":"0018B20000000165","projectId":"TEST","description":"Testovaci GPS cidlo","model":"ARF8084BA","vendor":"Adeunis RF"}
]}

Teplotni cidlo:
{"_meta":{"status":"SUCCESS","count":25},
"records":[
{"devEUI":"4786E6ED00350042","fPort":8,"fCntUp":24427,"aDRbit":1,"fCntDn":1333,"payloadHex":"8160696c1e00941bca",
"micHex":"","lrrRSSI":-49,"lrrSNR":8.25,"spFact":12,"subBand":"G1","channel":"LC1","devLrrCnt":6,"lrrid":"290000BC",
"lrrLAT":0,"lrrLON":0,"lrrs":[
{"Lrrid":"290000BC","LrrRSSI":-49,"LrrSNR":8.25,"LrrESP":-49.605556},
{"Lrrid":"29000048","LrrRSSI":-59,"LrrSNR":8.5,"LrrESP":-59.573822},
{"Lrrid":"290000F5","LrrRSSI":-101,"LrrSNR":7.5,"LrrESP":-101.710815}],
"createdAt":"2016-07-19T13:12:37+0000"},
{"devEUI":"4786E6ED00350042","fPort":8,"fCntUp":24426,"aDRbit":1,"fCntDn":1333,"payloadHex":"8160696c1e00941bca",
atd.

GPS:
{"_meta":{"status":"SUCCESS","count":2},
"records":[
{"devEUI":"0018B20000000165","fPort":1,"fCntUp":9154,"aDRbit":1,"fCntDn":11076,"payloadHex":"8e2543de0cee",
"micHex":"","lrrRSSI":-107,"lrrSNR":6.75,"spFact":12,"subBand":"G1","channel":"LC1","devLrrCnt":1,"lrrid":"29000034",
"lrrLAT":50.227592,"lrrLON":14.587337,"lrrs":[
{"Lrrid":"29000034","LrrRSSI":-107,"LrrSNR":6.75,"LrrESP":-107.832695}],
"createdAt":"2016-07-18T20:02:50+0000"},
{"devEUI":"0018B20000000165","fPort":1,"fCntUp":9153,"aDRbit":1,"fCntDn":11075,"payloadHex":"8e2641dd0cec",
atd.

RN2483:
devEUI:  0004A30B001B25AC
DevAddr: 001B25AC
NwkSKey: 2A7E2BBF2941656B213413450C73E098
AppSKey: 5899649556348C136320BC230275D1C9

Status  = SUCCESS
Počet = 4
Time   = 2016-07-22T08:45:07+0000
Port   = 1
P-load = 0123456789abcdef
Lat    = 50.101646   // nejbližší base, zatím ne moje QTH
Lon    = 14.3434
* * *
Time   = 2016-07-22T07:53:57+0000c atd.
*/