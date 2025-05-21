package filter;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter(urlPatterns = { "/admin/*", "/teacher/*", "/student/*" })
public class AuthenticationFilter implements Filter {

  @Override
  public void init(FilterConfig filterConfig) throws ServletException {
    // Initialization code if needed
  }

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {
    try {
      HttpServletRequest httpRequest = (HttpServletRequest) request;
      HttpServletResponse httpResponse = (HttpServletResponse) response;
      HttpSession session = httpRequest.getSession(false);

      // Get the request URI
      String requestURI = httpRequest.getRequestURI();
      String contextPath = httpRequest.getContextPath();

      // Check if this is a login-related request
      boolean isLoginRequest = requestURI.equals(contextPath + "/login") ||
          requestURI.equals(contextPath + "/login_process") ||
          requestURI.endsWith("login.jsp");

      // If it's a login request, let it pass through
      if (isLoginRequest) {
        chain.doFilter(request, response);
        return;
      }

      // Check if user is logged in
      if (session != null && session.getAttribute("user") != null) {
        // User is logged in, allow access
        chain.doFilter(request, response);
      } else {
        // User is not logged in, redirect to login page
        httpResponse.sendRedirect(contextPath + "/login?error=unauthenticated");
      }
    } catch (Exception e) {
      // Log the error
      e.printStackTrace();
      // Forward to error page
      request.setAttribute("error", "An error occurred during authentication");
      request.getRequestDispatcher("/WEB-INF/view/error/500.jsp").forward(request, response);
    }
  }

  @Override
  public void destroy() {
    // Cleanup code if needed
  }
}