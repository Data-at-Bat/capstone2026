package com.dataatbat.data_at_bat_api.middleware;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;

import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;

import java.io.IOException;


import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class JWTFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // LET CORS PREFLIGHT REQUESTS PASS THROUGH IMMEDIATELY
        // This is required for Flutter Web to establish a connection with the server
        if (httpRequest.getMethod().equalsIgnoreCase("OPTIONS")) {
            chain.doFilter(request, response);
            return;
        }

        // Resume normal JWT checks for all other requests
        if (requiresAuth(httpRequest)) {
            String token = httpRequest.getHeader("Authorization");

            if (token != null && token.startsWith("Bearer ")) {
                try {
                    token = token.substring(7); // Remove "Bearer " part
                    request.setAttribute("uid", getUID(token));
                    chain.doFilter(request, response);
                }
                catch (FirebaseAuthException exception){
                    httpResponse.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid Token");
                }
            } else {
                httpResponse.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Authorization header is missing");
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