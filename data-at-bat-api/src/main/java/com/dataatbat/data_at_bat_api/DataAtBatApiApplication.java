package com.dataatbat.data_at_bat_api;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;


// If intending to use the run method, add "implements CommandLineRunner"
@SpringBootApplication
public class DataAtBatApiApplication {
//	private static final Logger logger = LoggerFactory.getLogger(DataAtBatApiApplication.class);

	public static void main(String[] args) {
		Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();
		dotenv.entries().forEach(e -> System.setProperty(e.getKey(), e.getValue()));
		SpringApplication.run(DataAtBatApiApplication.class, args);
	}

//	@Override
//	public void run(String... args) {
//	}

}
