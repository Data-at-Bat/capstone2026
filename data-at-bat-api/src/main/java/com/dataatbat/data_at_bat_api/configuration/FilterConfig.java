package com.dataatbat.data_at_bat_api.configuration;

import com.dataatbat.data_at_bat_api.middleware.JWTFilter;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class FilterConfig {

    @Bean
    public FilterRegistrationBean<JWTFilter> loggingFilter() {
        FilterRegistrationBean<JWTFilter> registrationBean = new FilterRegistrationBean<>();
        registrationBean.setFilter(new JWTFilter());
        registrationBean.addUrlPatterns("/user");
        registrationBean.addUrlPatterns(("/favorites"));
        return registrationBean;
    }
}