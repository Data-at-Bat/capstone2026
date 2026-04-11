package com.dataatbat.data_at_bat_api;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import io.github.cdimascio.dotenv.Dotenv;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;


// If intending to use the run method, add "implements CommandLineRunner"
@SpringBootApplication
public class DataAtBatApiApplication {
    private static final Logger logger = LoggerFactory.getLogger(DataAtBatApiApplication.class);

	public static void main(String[] args) {
		Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();
		dotenv.entries().forEach(e -> System.setProperty(e.getKey(), e.getValue()));

		String googleCredentials = System.getProperty("GOOGLE_APPLICATION_CREDENTIALS");
		if (googleCredentials != null) {
			try {
				FileInputStream serviceAccountFile = new FileInputStream(googleCredentials);
				FirebaseOptions options = FirebaseOptions.builder()
						.setCredentials(GoogleCredentials.fromStream(serviceAccountFile))
						.build();

				FirebaseApp.initializeApp(options);
				logger.info("Successfully initialized Firebase App");
			}
			catch (FileNotFoundException exception) {
				logger.error("Unable to locate Google Service Account Key. Connection to Firebase unsuccessful");
			} catch (IOException e) {
                logger.error(e.getMessage());
            }
        }
		else {
			logger.info("Google Application Credentials not provided. Connection to Firebase unsuccessful");
		}

		SpringApplication.run(DataAtBatApiApplication.class, args);
	}

//	@Override
//	public void run(String... args) {
//	}

}
