package com.boxfuse.samples.javawarhello;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(urlPatterns = "/hello", loadOnStartup = 1)
public class HelloServlet extends HttpServlet {

    @Override
    public void init() throws ServletException {
        System.out.println("HelloServlet: application started on the stage node");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("text/plain; charset=UTF-8");
        response.setStatus(HttpServletResponse.SC_OK);
        response.getWriter().println("Hello from the DevOps certification stage!");
    }
}
