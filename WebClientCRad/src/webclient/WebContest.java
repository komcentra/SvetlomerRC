package webclient;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

public class WebContest {

    public static void main(String[] args) {
        WebContest app = new WebContest();
        app.retrieveSolar ();
    }

    void retrieveSolar () {
        int samples = 99;   // nastavení max. počtu čtených vzorků
        String[] datalines = new String[samples];
        try {
            URL iurl = new URL("https://api.pripoj.me/message/get/0004A30B00195511?token=Y7J3MvLLMrXCtzpiQuPgHHu7wO046Jx6&limit="+String.valueOf(samples));
            // načti stream a převeď ho na byte[]
            InputStream is = iurl.openStream();
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            while (true) {
                int r = is.read(buffer);
                if (r == -1) break;
                out.write(buffer, 0, r);
            }
            byte[] jsonData = out.toByteArray();
            double osvit, batt;
            // analyzuj data ve formátu Jackson
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode rootNode = objectMapper.readTree(jsonData);
            JsonNode metaNode  = rootNode.path("_meta");
            JsonNode statNode  = metaNode.path("status");
            if (statNode.asText().equals ("SUCCESS")) {
                JsonNode recoNode = rootNode.path("records");
		if (recoNode.isArray()) {
                    int i=0;
                    for (JsonNode node : recoNode) {
                        String times   = node.path("createdAt").asText();
                        // analyzuj payload
                        String payload = node.path("payloadHex").asText();
                        if (payload.length()==8){
                            if (payload.substring(0,2).equals("55")) {
                                osvit = (double) Integer.parseInt(payload.substring(2,5));
                                batt  = (double) Integer.parseInt(payload.substring(5,8));
     //                           osvit = Math.pow (1.009960258, osvit);
                                batt  = (batt-100)*2*5.07/899;
                                times = times.substring(0,10)+" "+times.substring(11,19)+";"+payload.substring(2,5)+";"/*+String.format("%.0f", osvit)+";"*/+String.format("%.2f", batt);
                                datalines[i] = times;
                                i++;
                            }
                        }
                    }
                    // zde lze případně datalines upravit
                    // ulož data do CSV
                    try {
	                File file = new File("C:\\temp\\svetlomer.csv");
			if (!file.exists()) {
                            file.createNewFile();
			}
			FileWriter fw = new FileWriter(file.getAbsoluteFile());
                        try (BufferedWriter bw = new BufferedWriter(fw)) {
                            for (String dataline:datalines){
                                bw.append(dataline+"\r\n");
                            }
                            bw.close();
                        }
                    } catch (IOException x) {
                        System.out.println(x.getMessage());
                    }
                }
            }
        } catch (IOException | NumberFormatException e) {
            System.out.println (e.getMessage());
        }
    }
}