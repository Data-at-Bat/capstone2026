package com.dataabat.data_at_bat_api;

import io.github.cdimascio.dotenv.Dotenv;
import jakarta.transaction.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;


@SpringBootApplication
public class DataAtBatApiApplication implements CommandLineRunner {
	private static final Logger logger = LoggerFactory.getLogger(DataAtBatApiApplication.class)

	public DataAtBatApiApplication() {
	}

	public static void main(String[] args) {
		Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();
		dotenv.entries().forEach(e -> System.setProperty(e.getKey(), e.getValue()));
		SpringApplication.run(DataAtBatApiApplication.class, args);
	}

	@Override
	@Transactional
	public void run(String... args) {

	}

}
