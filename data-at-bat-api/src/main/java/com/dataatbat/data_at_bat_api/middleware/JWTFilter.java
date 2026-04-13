package com.dataatbat.data_at_bat_api.middleware;

import com.google.api.Http;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import java.io.IOException;
import java.util.UUID;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class JWTFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;

        if (requiresAuth(httpRequest)) {
            String token = httpRequest.getHeader("Authorization");

            if (token != null && token.startsWith("Bearer ")) {
                try {
                    token = token.substring(7); // Remove "Bearer " part
                    request.setAttribute("uid", getUID(token));
                    chain.doFilter(request, response);
                }
                catch (FirebaseAuthException exception){
                    ((HttpServletResponse) response).sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid Token");
                }
            } else {
                ((HttpServletResponse) response).sendError(HttpServletResponse.SC_UNAUTHORIZED, "Authorization header is missing");
            }
        }
        else {
            chain.doFilter(request, response);
        }
    }

    private String getUID(String token) throws FirebaseAuthException {
        return FirebaseAuth.getInstance().verifyIdToken(token).getUid();
    }

    private Boolean requiresAuth(HttpServletRequest request) {
        return !request.getRequestURI().endsWith("/user") || !request.getMethod().equalsIgnoreCase("POST");
    }
}