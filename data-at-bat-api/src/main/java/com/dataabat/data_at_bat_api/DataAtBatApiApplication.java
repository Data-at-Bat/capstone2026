package com.dataabat.data_at_bat_api;

import io.github.cdimascio.dotenv.Dotenv;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;


@SpringBootApplication
public class DataAtBatApiApplication implements CommandLineRunner {
	private static final Logger logger = LoggerFactory.getLogger(DataAtBatApiApplication.class);

	public static void main(String[] args) {
		Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();
		dotenv.entries().forEach(e -> System.setProperty(e.getKey(), e.getValue()));
		SpringApplication.run(DataAtBatApiApplication.class, args);
	}

	@Override
	public void run(String... args) {
		logger.info("Temporary logging statement so the linter stops yelling about an unused variable");
	}

}
