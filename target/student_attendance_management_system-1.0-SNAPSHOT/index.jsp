<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!-- <%--<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>--%> -->
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%
  // Simulate dynamic data for the graduation section
  List<Map<String, String>> graduates = new ArrayList<>();
  Map<String, String> grad1 = new HashMap<>();
  grad1.put("name", "Astha");
  grad1.put("title", "A Journey to Leadership");
  grad1.put("story", "Astha transformed from a shy student to a confident leader, spearheading community projects and earning a prestigious internship at a global firm. Her dedication and growth at Itahari International College paved the way for her success.");
  grad1.put("image", "Images/Astha.jpg");
  Map<String, String> grad2 = new HashMap<>();
  grad2.put("name", "Umar");
  grad2.put("title", "Innovating the Future");
  grad2.put("story", "Umar's groundbreaking research in sustainable technology won national awards, paving the way for a career in environmental engineering. His time at our college fueled his passion for innovation.");
  grad2.put("image", "Images/Umar.jpg");
  Map<String, String> grad3 = new HashMap<>();
  grad3.put("name", "Tumyhang");
  grad3.put("title", "Breaking Barriers");
  grad3.put("story", "Tumyhang overcame challenges to become the first in her family to graduate, now inspiring others as a motivational speaker and educator. Her resilience and support from our community made her journey possible.");
  grad3.put("image", "Images/tume.jpg");
  Map<String, String> grad4 = new HashMap<>();
  grad4.put("name", "Nicholos");
  grad4.put("title", "Global Impact");
  grad4.put("story", "Nicholos's dedication to social justice led him to work with international NGOs, making a difference in communities worldwide. His education at Itahari International College equipped him with the skills to create change.");
  grad4.put("image", "Images/nicholos.jpg");
  graduates.add(grad1);
  graduates.add(grad2);
  graduates.add(grad3);
  graduates.add(grad4);
  request.setAttribute("graduates", graduates);

  // Get current date for dynamic display
  SimpleDateFormat sdf = new SimpleDateFormat("MMMM dd, yyyy");
  String currentDate = sdf.format(new Date());
  request.setAttribute("currentDate", currentDate);
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Itahari International College's Student Attendance Management System - Streamline attendance tracking for admins, teachers, and students.">
  <meta name="keywords" content="Itahari International College, attendance management, student portal, education technology">
  <meta name="author" content="Itahari International College">
  <title>Student Attendance Management System</title>
  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png">
  <!-- AOS Animation Library -->
  <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
  <!-- Font Awesome for Icons -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 0;
      padding: 0;
      line-height: 1.6;
      background-color: #f5f5f5;
    }

    .hero-bg {
      background: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url('Images/College Image.jpg');
      background-size: cover;
      background-position: center;
      height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .navbar {
      transition: all 0.3s ease;
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      z-index: 50;
    }

    .navbar.scrolled {
      background-color: rgba(255, 255, 255, 0.95);
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    }

    .card {
      transition: transform 0.3s ease, box-shadow 0.3s ease;
    }

    .card:hover {
      transform: translateY(-10px);
      box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
    }

    .cta-button {
      transition: all 0.3s ease;
    }

    .cta-button:hover {
      transform: scale(1.05);
      box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
    }

    /* Note Styles */
    .note {
      background-color: #f0f8ff;
      border-left: 4px solid #1e90ff;
      padding: 16px;
      margin: 16px 0;
      font-size: 16px;
      color: #4B5563;
      border-radius: 4px;
    }

    /* About Section Styles */
    .about-section {
      padding: 80px 16px;
      background-color: #fff;
    }

    .about-container {
      max-width: 1200px;
      margin: 0 auto;
      text-align: center;
    }

    .about-tabs {
      display: flex;
      justify-content: center;
      gap: 16px;
      margin-bottom: 32px;
    }

    .about-tab {
      background-color: #1e90ff;
      color: #fff;
      padding: 12px 24px;
      border-radius: 9999px;
      cursor: pointer;
      font-size: 16px;
      font-weight: 600;
      transition: background-color 0.3s ease, transform 0.3s ease;
    }

    .about-tab:hover {
      background-color: #ffd700;
      color: #1e90ff;
      transform: scale(1.05);
    }

    .about-tab.active {
      background-color: #ffd700;
      color: #1e90ff;
    }

    .about-content {
      display: none;
      padding: 40px;
      border-radius: 8px;
      box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
      min-height: 400px;
      align-items: center;
      justify-content: center;
      flex-direction: column;
      position: relative;
      overflow: hidden;
    }

    .about-content.active {
      display: flex;
    }

    .about-content img {
      width: 100%;
      height: auto;
      border-radius: 8px;
      object-fit: cover;
      position: absolute;
      top: 0;
      left: 0;
      z-index: 1;
      min-height: 100%;
    }

    .about-content .content-text {
      position: relative;
      z-index: 2;
      background-color: rgba(255, 255, 255, 0.85);
      padding: 24px;
      border-radius: 8px;
      max-width: 800px;
      margin: 0 auto;
    }

    #mission .content-text {
      background-color: rgba(255, 255, 255, 0.7);
      padding: 32px;
      border: 1px solid rgba(0, 0, 0, 0.1);
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    }

    #mission .content-text h3,
    #mission .content-text p {
      text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
    }

    .about-content h3 {
      font-size: 28px;
      font-weight: bold;
      color: #000000;
      margin-bottom: 16px;
    }

    .about-content p {
      font-size: 18px;
      color: #000000;
      margin: 0;
    }

    /* Library Section Styles */
    #library {
      padding: 80px 16px;
      background-color: #fff;
    }

    #library .library-container {
      max-width: 1200px;
      margin: 0 auto;
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 32px;
      flex-wrap: wrap;
      justify-content: space-between;
    }

    #library .library-images {
      flex: 1;
      min-width: 300px;
      display: flex;
      flex-direction: column;
      gap: 16px;
    }

    #library .library-content {
      flex: 1;
      min-width: 300px;
      text-align: left;
    }

    #library img {
      width: 100%;
      max-width: 400px;
      border-radius: 8px;
    }

    /* Teaching Section Styles */
    #teaching {
      padding: 80px 16px;
      background-color: #fff;
    }

    #teaching .teaching-container {
      max-width: 1200px;
      margin: 0 auto;
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 32px;
      flex-wrap: wrap;
      justify-content: space-between;
    }

    #teaching .teaching-content {
      flex: 1;
      min-width: 300px;
      text-align: left;
    }

    #teaching .teaching-image {
      flex: 1;
      min-width: 300px;
      text-align: right;
    }

    #teaching img {
      width: 100%;
      max-width: 600px;
      border-radius: 8px;
    }

    /* Classroom Section Styles */
    #classroom {
      padding: 80px 16px;
      background-color: #fff;
    }

    #classroom .classroom-container {
      max-width: 1200px;
      margin: 0 auto;
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 32px;
      flex-wrap: wrap;
      justify-content: space-between;
    }

    #classroom .classroom-images {
      flex: 1;
      min-width: 300px;
      display: flex;
      flex-direction: column;
      gap: 16px;
    }

    #classroom .classroom-content {
      flex: 1;
      min-width: 300px;
      text-align: left;
    }

    #classroom img {
      width: 100%;
      max-width: 400px;
      border-radius: 8px;
    }

    /* Campus Life Section Styles */
    #campus {
      padding: 80px 16px;
      background-color: #fff;
    }

    #campus .campus-container {
      max-width: 1200px;
      margin: 0 auto;
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 32px;
      flex-wrap: wrap;
      justify-content: space-between;
    }

    #campus .campus-content {
      flex: 1;
      min-width: 300px;
      text-align: left;
    }

    #campus .campus-image {
      flex: 1;
      min-width: 300px;
      text-align: right;
    }

    #campus img {
      width: 100%;
      max-width: 600px;
      border-radius: 8px;
    }

    /* Graduation Section Styles */
    #graduation {
      padding: 80px 16px;
      background: linear-gradient(135deg, #f0f8ff 0%, #e6e6fa 100%);
    }

    #graduation .graduation-container {
      max-width: 1200px;
      margin: 0 auto;
    }

    #graduation h2 {
      font-size: 36px;
      font-weight: bold;
      text-align: center;
      margin-bottom: 48px;
      color: #2f4f4f;
    }

    #graduation .graduate-card {
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 32px;
      background-color: #fff;
      border-radius: 12px;
      padding: 24px;
      margin-bottom: 32px;
      box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
      transition: transform 0.3s ease, box-shadow 0.3s ease;
    }

    #graduation .graduate-card:hover {
      transform: scale(1.03);
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
    }

    #graduation .graduate-image {
      flex: 1;
      min-width: 200px;
    }

    #graduation .graduate-image img {
      width: 100%;
      max-width: 300px;
      border-radius: 8px;
    }

    #graduation .graduate-story {
      flex: 2;
      text-align: left;
    }

    #graduation .graduate-story h3 {
      font-size: 24px;
      font-weight: 600;
      color: #1e90ff;
      margin-bottom: 16px;
    }

    #graduation .graduate-story p {
      font-size: 16px;
      color: #4B5563;
      line-height: 1.8;
    }

    /* Newsletter Section */
    #newsletter {
      padding: 80px 16px;
      background-color: #f0f8ff;
    }

    .newsletter-container {
      max-width: 600px;
      margin: 0 auto;
      text-align: center;
    }

    #newsletter input[type="email"] {
      padding: 12px;
      width: 100%;
      max-width: 400px;
      border: 1px solid #ccc;
      border-radius: 4px;
      margin-bottom: 16px;
      font-size: 16px;
    }

    #newsletter button {
      background-color: #1e90ff;
      color: #fff;
      padding: 12px 24px;
      border: none;
      border-radius: 4px;
      font-size: 16px;
      cursor: pointer;
      transition: background-color 0.3s ease;
    }

    #newsletter button:hover {
      background-color: #ffd700;
      color: #1e90ff;
    }

    /* Global Image Hover Effect */
    img:not(.about-content img) {
      transition: transform 0.3s ease, position 0.3s ease, z-index 0.3s ease;
      position: relative;
      z-index: 1;
    }

    img:not(.about-content img):hover {
      transform: scale(2);
      z-index: 1000;
      position: relative;
    }

    /* Footer Styles */
    footer {
      background-color: #2f4f4f;
      padding: 40px 16px;
    }

    .footer-container {
      max-width: 1200px;
      margin: 0 auto;
      display: flex;
      flex-wrap: wrap;
      justify-content: space-between;
      gap: 32px;
    }

    .footer-column {
      flex: 1;
      min-width: 200px;
    }

    .footer-column h3 {
      color: #fff;
      font-size: 18px;
      margin-bottom: 16px;
    }

    .footer-column p,
    .footer-column a {
      color: #ccc;
      font-size: 14px;
      line-height: 1.8;
      text-decoration: none;
    }

    .footer-column a:hover {
      color: #ffd700;
    }

    .social-icons {
      display: flex;
      gap: 16px;
    }

    .social-icons a {
      color: #fff;
      font-size: 20px;
      transition: color 0.3s ease;
    }

    .social-icons a:hover {
      color: #ffd700;
    }

    @media (max-width: 768px) {
      #teaching .teaching-container,
      #library .library-container,
      #classroom .classroom-container,
      #campus .campus-container {
        flex-direction: column;
        text-align: center;
      }

      #teaching .teaching-content,
      #library .library-content,
      #classroom .classroom-content,
      #campus .campus-content {
        text-align: center;
      }

      #teaching .teaching-image,
      #library .library-images,
      #classroom .classroom-images,
      #campus .campus-image {
        text-align: center;
      }

      #graduation .graduate-card {
        flex-direction: column;
        text-align: center;
      }

      #graduation .graduate-story {
        text-align: center;
      }

      img:not(.about-content img):hover {
        transform: scale(1.5);
      }

      .footer-container {
        flex-direction: column;
        text-align: center;
      }

      .social-icons {
        justify-content: center;
      }

      .about-content img {
        min-height: 300px;
      }

      .about-content .content-text {
        padding: 16px;
      }

      .about-content h3 {
        font-size: 24px;
      }

      .about-content p {
        font-size: 16px;
      }

      #mission .content-text {
        padding: 24px;
      }
    }
  </style>
</head>
<body>
<!-- Navbar -->
<nav class="navbar" style="background-color: #fff;" data-aos="fade-down">
  <div style="max-width: 1200px; margin: 0 auto; padding: 16px; display: flex; justify-content: space-between; align-items: center;">
    <div style="font-size: 24px; font-weight: bold; color: #1e90ff;">Itahari International College</div>
    <div style="display: flex; gap: 24px;">
      <a href="index.jsp" style="color: #4B5563; text-decoration: none; font-size: 16px;">Home</a>
      <a href="#about" style="color: #4B5563; text-decoration: none; font-size: 16px;">About</a>
      <a href="#features" style="color: #4B5563; text-decoration: none; font-size: 16px;">Features</a>
      <a href="#contact" style="color: #4B5563; text-decoration: none; font-size: 16px;">Contact</a>
      <%-- JSTL is commented out, so using scriptlet for session check --%>
      <%
        String username = (String) session.getAttribute("username");
        if (username != null) {
      %>
<%--      <a href="/logout" style="background-color: #1e90ff; color: #fff; padding: 8px 16px; border-radius: 4px; text-decoration: none; font-size: 16px;">Logout</a>--%>
      <%
      } else {
      %>
      <a href="${pageContext.request.contextPath}/Nav_login" style="background-color: #1e90ff; color: #fff; padding: 8px 16px; border-radius: 4px; text-decoration: none; font-size: 16px;">Login</a>
      <a href="${pageContext.request.contextPath}/Nav_register" style="background-color: #1e90ff; color: #fff; padding: 8px 16px; border-radius: 4px; text-decoration: none; font-size: 16px;">Register</a>
      <%
        }
      %>
    </div>
  </div>
</nav>

<!-- Hero Section -->
<section id="home" class="hero-bg">
  <div style="max-width: 1200px; margin: 0 auto; text-align: center;" data-aos="fade-up" data-aos-duration="1200">
    <h1 style="font-size: 48px; font-weight: bold; margin-bottom: 16px; color: #fff;">Student Attendance Management System</h1>
    <p style="font-size: 20px; margin-bottom: 16px; color: #fff;">
      Welcome to Itahari International College's innovative platform designed to simplify attendance tracking for students, teachers, and administrators.
      <%
        if (username != null) {
      %>
      <br>Hello, <%= username %>! We're glad you're here.
      <%
        }
      %>
    </p>
    <p style="font-size: 18px; margin-bottom: 32px; color: #fff;">Our system ensures seamless communication and real-time updates, making it easier for everyone to stay connected and informed. Get started today and experience a smarter way to manage attendance!</p>
    <a href="${pageContext.request.contextPath}/Nav_login" class="cta-button" style="background-color: #ffd700; color: #1e90ff; padding: 12px 24px; border-radius: 9999px; font-weight: 600; text-decoration: none;" data-aos="zoom-in" data-aos-delay="200">Get Started</a>
    <div class="note" style="color: #fff; background-color: rgba(0, 0, 0, 0.5); max-width: 600px; margin: 16px auto;" data-aos="fade-up" data-aos-delay="300">
      Today is <%= currentDate %>. Check your portal for the latest updates!
    </div>
  </div>
</section>

<!-- About Section -->
<section id="about" class="about-section">
  <div class="about-container">
    <h2 style="font-size: 36px; font-weight: bold; margin-bottom: 24px; color: #2f4f4f;" data-aos="fade-up">About Our College</h2>
    <p style="font-size: 18px; color: #4B5563; max-width: 800px; margin: 0 auto 32px;" data-aos="fade-up" data-aos-delay="100">Discover what makes Itahari International College a leading institution for higher education. From our mission to our state-of-the-art facilities, we are committed to shaping the future of our students.</p>
    <div class="note" data-aos="fade-up" data-aos-delay="150">Note: Click the tabs below to explore different aspects of our college and see how we support our students' journey.</div>
    <div class="about-tabs" data-aos="fade-up" data-aos-delay="200">
      <div class="about-tab active" data-tab="mission">Our Mission</div>
      <div class="about-tab" data-tab="facilities">Facilities</div>
      <div class="about-tab" data-tab="community">Community</div>
    </div>
    <div class="about-content active" id="mission" data-aos="fade-left" data-aos-duration="1000">
      <img src="Images/Graduation.jpg" alt="Our Mission">
      <div class="content-text">
        <h3>Our Mission</h3>
        <p>At Itahari International College, our mission is to provide a transformative educational experience that fosters academic excellence, personal growth, and global citizenship. We empower our students to become innovative leaders through a supportive and inclusive environment.</p>
        <p style="margin-top: 16px;">We believe in nurturing talent and encouraging curiosity, ensuring every student has the opportunity to thrive and make a positive impact in the world.</p>
      </div>
    </div>
    <div class="about-content" id="facilities" data-aos="fade-left" data-aos-duration="1000">
      <img src="Images/Classes.jpg" alt="State-of-the-Art Facilities">
      <div class="content-text">
        <h3>State-of-the-Art Facilities</h3>
        <p>Our campus is equipped with modern classrooms, advanced laboratories, and a comprehensive library, all designed to enhance the learning experience. Whether you're conducting research or collaborating on projects, our facilities provide the perfect environment for success.</p>
        <p style="margin-top: 16px;">From high-speed Wi-Fi to cutting-edge technology, we ensure our students have access to the tools they need to excel in their studies and beyond.</p>
      </div>
    </div>
    <div class="about-content" id="community" data-aos="fade-left" data-aos-duration="1000">
      <img src="Images/Vibe Environment.jpg" alt="Vibrant Community">
      <div class="content-text">
        <h3>Vibrant Community</h3>
        <p>Join a diverse and welcoming community at Itahari International College, where students from all backgrounds come together to learn, grow, and connect. Participate in clubs, events, and collaborative projects that create lasting memories and lifelong friendships.</p>
        <p style="margin-top: 16px;">Our inclusive environment encourages everyone to share their unique perspectives, making our campus a vibrant hub of creativity and collaboration.</p>
      </div>
    </div>
  </div>
</section>

<!-- Features Section -->
<section id="features" style="padding: 80px 16px; background-color: #fff;">
  <div style="max-width: 1200px; margin: 0 auto;">
    <h2 style="font-size: 36px; font-weight: bold; text-align: center; margin-bottom: 24px; color: #2f4f4f;" data-aos="fade-up">Features of Our System</h2>
    <p style="font-size: 18px; color: #4B5563; text-align: center; max-width: 800px; margin: 0 auto 32px;" data-aos="fade-up" data-aos-delay="100">Our Student Attendance Management System is designed to make life easier for everyone involved in the educational process. Explore the key features below to see how our platform supports admins, teachers, and students.</p>
    <div class="note" data-aos="fade-up" data-aos-delay="150">Tip: Log in to your respective portal (Admin, Teacher, or Student) to access these features and streamline your daily tasks!</div>
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 32px;">
      <div class="card" style="background-color: #f0f8ff; padding: 24px; border-radius: 8px; text-align: center;" data-aos="flip-left" data-aos-duration="800">
        <h3 style="font-size: 24px; font-weight: 600; margin-bottom: 16px; color: #1e90ff;">Admin Dashboard</h3>
        <p style="color: #4B5563;">Manage student records, track attendance trends, and generate detailed reports with ease. The admin dashboard provides a centralized hub for all administrative tasks, saving time and improving efficiency.</p>
      </div>
      <div class="card" style="background-color: #f0f8ff; padding: 24px; border-radius: 8px; text-align: center;" data-aos="flip-left" data-aos-duration="800" data-aos-delay="200">
        <h3 style="font-size: 24px; font-weight: 600; margin-bottom: 16px; color: #1e90ff;">Teacher Portal</h3>
        <p style="color: #4B5563;">Mark attendance, monitor student progress, and communicate directly with students through our intuitive teacher portal. Stay organized and keep your classes running smoothly.</p>
      </div>
      <div class="card" style="background-color: #f0f8ff; padding: 24px; border-radius: 8px; text-align: center;" data-aos="flip-left" data-aos-duration="800" data-aos-delay="400">
        <h3 style="font-size: 24px; font-weight: 600; margin-bottom: 16px; color: #1e90ff;">Student Access</h3>
        <p style="color: #4B5563;">Access your attendance records, view class schedules, and receive real-time notifications from anywhere. The student portal keeps you informed and connected to your academic journey.</p>
      </div>
    </div>
  </div>
</section>

<!-- Library Section -->
<section id="library" style="padding: 80px 16px; background-color: #fff;">
  <div class="library-container">
    <div style="width: 100%; text-align: center; margin-bottom: 32px;" data-aos="fade-up">
      <h2 style="font-size: 36px; font-weight: bold; margin-bottom: 24px; color: #2f4f4f;">Our Library</h2>
      <p style="font-size: 18px; color: #4B5563; max-width: 800px; margin: 0 auto;">The library at Itahari International College is more than just a place to study—it's a hub of knowledge and inspiration. Explore our vast collection of books, journals, and digital resources tailored to support your academic goals.</p>
      <div class="note" style="max-width: 800px; margin: 16px auto;">Note: Visit the library during open hours (8 AM - 6 PM) or access our online resources 24/7 through the student portal.</div>
    </div>
    <div class="library-images" data-aos="fade-right" data-aos-duration="1000">
      <img src="Images/Librar.jpg" alt="Student Studying in Library">
      <img src="Images/Library.jpg" alt="Library Shelves">
    </div>
    <div class="library-content" data-aos="fade-left" data-aos-duration="1000">
      <p style="color: #4B5563; font-size: 18px; max-width: 500px;">Our library offers a quiet and resourceful space for students to study and research, with an extensive collection of books, e-books, and digital resources. Whether you're preparing for exams or exploring new topics, our library is your go-to destination.</p>
    </div>
  </div>
</section>

<!-- Teaching Section -->
<section id="teaching" style="padding: 80px 16px; background-color: #fff;">
  <div class="teaching-container">
    <div style="width: 100%; text-align: center; margin-bottom: 32px;" data-aos="fade-up">
      <h2 style="font-size: 36px; font-weight: bold; margin-bottom: 24px; color: #2f4f4f;">Teaching Excellence</h2>
      <p style="font-size: 18px; color: #4B5563; max-width: 800px; margin: 0 auto;">Our faculty members are passionate educators dedicated to inspiring and guiding students. Through interactive lessons and personalized support, we ensure every student reaches their full potential.</p>
    </div>
    <div class="teaching-content" data-aos="fade-left" data-aos-duration="1000">
      <p style="color: #4B5563; font-size: 18px; max-width: 500px;">Experience engaging and interactive lessons designed to foster a deep understanding of your subjects. Our teachers use innovative methods to make learning enjoyable and effective.</p>
      <div class="note">Tip: Connect with your teachers via the teacher portal to ask questions or schedule one-on-one sessions.</div>
    </div>
    <div class="teaching-image" data-aos="fade-right" data-aos-duration="1000">
      <img src="Images/Hall Image.jpg" alt="Professor Teaching">
    </div>
  </div>
</section>

<!-- Classroom Section -->
<section id="classroom" style="padding: 80px 16px; background-color: #fff;">
  <div class="classroom-container">
    <div style="width: 100%; text-align: center; margin-bottom: 32px;" data-aos="fade-up">
      <h2 style="font-size: 36px; font-weight: bold; margin-bottom: 24px; color: #2f4f4f;">Classroom Environment</h2>
      <p style="font-size: 18px; color: #4B5563; max-width: 800px; margin: 0 auto;">Our classrooms are designed to spark creativity and collaboration, equipped with the latest technology to enhance your learning experience.</p>
    </div>
    <div class="classroom-images" data-aos="fade-right" data-aos-duration="1000">
      <img src="Images/class.webp" alt="Students in Lecture Hall">
    </div>
    <div class="classroom-content" data-aos="fade-left" data-aos-duration="1000">
      <p style="color: #4B5563; font-size: 18px; max-width: 500px;">Step into our modern classrooms, where interactive whiteboards and collaborative spaces create an ideal setting for active learning. Whether it's group discussions or hands-on projects, our environment encourages participation and innovation.</p>
      <div class="note">Note: Check your class schedule in the student portal to stay updated on room assignments and timings.</div>
    </div>
  </div>
</section>

<!-- Campus Life Section -->
<section id="campus" style="padding: 80px 16px; background-color: #fff;">
  <div class="campus-container">
    <div style="width: 100%; text-align: center; margin-bottom: 32px;" data-aos="fade-up">
      <h2 style="font-size: 36px; font-weight: bold; margin-bottom: 24px; color: #2f4f4f;">Campus Life</h2>
      <p style="font-size: 18px; color: #4B5563; max-width: 800px; margin: 0 auto;">Life at Itahari International College is vibrant and full of opportunities. From social events to student clubs, there's something for everyone to enjoy and grow.</p>
    </div>
    <div class="campus-content" data-aos="fade-left" data-aos-duration="1000">
      <p style="color: #4B5563; font-size: 18px; max-width: 500px;">Our campus is a lively community with beautiful courtyards, exciting social events, and a supportive network of peers and faculty. Get involved in student organizations or attend cultural festivals to make the most of your college experience.</p>
      <div class="note">Tip: Follow our social media pages to stay updated on upcoming campus events and activities!</div>
    </div>
    <div class="campus-image" data-aos="fade-right" data-aos-duration="1000">
      <img src="Images/Uni.jpg" alt="Campus Courtyard">
    </div>
  </div>
</section>

<!-- Graduation Section -->
<section id="graduation" style="padding: 80px 16px; background: linear-gradient(135deg, #f0f8ff 0%, #e6e6fa 100%);">
  <div class="graduation-container">
    <h2 style="font-size: 36px; font-weight: bold; text-align: center; margin-bottom: 24px; color: #2f4f4f;" data-aos="fade-up">Graduation Achievements</h2>
    <p style="font-size: 18px; color: #4B5563; text-align: center; max-width: 800px; margin: 0 auto 32px;" data-aos="fade-up" data-aos-delay="100">Celebrate the success stories of our graduates who have gone on to achieve great things. Their journeys inspire us all and showcase the impact of an education at Itahari International College.</p>
    <div class="note" style="max-width: 800px; margin: 0 auto 32px;" data-aos="fade-up" data-aos-delay="150">Note: Are you an alumnus? Share your story with us by contacting our alumni office!</div>
    <%-- JSTL is commented out, so using scriptlet for looping --%>
    <%
      List<Map<String, String>> gradList = (List<Map<String, String>>) request.getAttribute("graduates");
      int index = 0;
      for (Map<String, String> graduate : gradList) {
    %>
    <div class="graduate-card" data-aos="fade-up" data-aos-duration="1000" data-aos-delay="<%= index * 200 %>">
      <div class="graduate-image">
        <img src="<%= graduate.get("image") %>" alt="Graduate <%= index + 1 %>">
      </div>
      <div class="graduate-story">
        <h3><%= graduate.get("title") %></h3>
        <p><%= graduate.get("story") %></p>
      </div>
    </div>
    <%
        index++;
      }
    %>
  </div>
</section>

<!-- Newsletter Section -->
<section id="newsletter" style="padding: 80px 16px; background-color: #f0f8ff;">
  <div class="newsletter-container">
    <h2 style="font-size: 36px; font-weight: bold; margin-bottom: 24px; color: #2f4f4f;" data-aos="fade-up">Stay Updated</h2>
    <p style="font-size: 18px; color: #4B5563; margin-bottom: 24px;" data-aos="fade-up" data-aos-delay="200">Join our newsletter to receive the latest news, event updates, and academic opportunities from Itahari International College. Stay connected with our community!</p>
    <div class="note" data-aos="fade-up" data-aos-delay="250">Note: Your email is safe with us, and you can unsubscribe at any time.</div>
    <%
      String message = request.getParameter("message");
      if (message != null) {
    %>
    <div class="note" style="background-color: #e0f7fa; color: #00695c;" data-aos="fade-up" data-aos-delay="300">
      <%= message %>
    </div>
    <%
      }
    %>
    <form action="${pageContext.request.contextPath}/Nav_login" method="post" data-aos="fade-up" data-aos-delay="400">
      <input type="email" name="email" placeholder="Enter your email" aria-label="Email for newsletter" required>
      <button type="submit">Subscribe</button>
    </form>
  </div>
</section>

<!-- Contact Section -->
<section id="contact" style="padding: 80px 16px; background-color: #2f4f4f;">
  <div style="max-width: 1200px; margin: 0 auto; text-align: center;">
    <h2 style="font-size: 36px; font-weight: bold; margin-bottom: 24px; color: #fff;" data-aos="fade-up">Contact Us</h2>
    <p style="font-size: 18px; color: #fff; max-width: 800px; margin: 0 auto 32px;" data-aos="fade-up" data-aos-delay="200">We're here to help! Whether you have questions about our attendance system, admissions, or campus life, our team is ready to assist you. Reach out via email, phone, or visit us in person.</p>
    <div class="note" style="max-width: 800px; margin: 0 auto 32px; background-color: rgba(255, 255, 255, 0.1); color: #fff;" data-aos="fade-up" data-aos-delay="250">Tip: For the fastest response, email us or call during business hours (9 AM - 5 PM, Monday to Friday).</div>
    <a href="mailto:info@itahariinternationalcollege.edu" style="background-color: #ffd700; color: #1e90ff; padding: 12px 24px; border-radius: 9999px; font-weight: 600; text-decoration: none;" data-aos="zoom-in" data-aos-delay="400">Email Us</a>
  </div>
</section>

<!-- Footer -->
<footer>
  <div class="footer-container">
    <div class="footer-column">
      <h3>About Us</h3>
      <p>Itahari International College is committed to academic excellence and fostering a vibrant student community. Learn more about our programs and values on our website.</p>
    </div>
    <div class="footer-column">
      <h3>Contact Info</h3>
      <p>Email: <a href="mailto:info@itahariinternationalcollege.edu">info@itahariinternationalcollege.edu</a></p>
      <p>Phone: +977-123-456-7890</p>
      <p>Address: Itahari, Sunsari, Nepal</p>
    </div>
    <div class="footer-column">
      <h3>Follow Us</h3>
      <div class="social-icons">
        <a href="https://facebook.com" aria-label="Facebook"><i class="fab fa-facebook-f"></i></a>
        <a href="https://twitter.com" aria-label="Twitter"><i class="fab fa-twitter"></i></a>
        <a href="https://instagram.com" aria-label="Instagram"><i class="fab fa-instagram"></i></a>
        <a href="https://linkedin.com" aria-label="LinkedIn"><i class="fab fa-linkedin-in"></i></a>
      </div>
    </div>
  </div>
  <p style="color: #fff; font-size: 16px; text-align: center; margin-top: 32px;">© <%= new java.util.Date().getYear() + 1900 %> Itahari International College. All rights reserved.</p>
</footer>

<!-- AOS Animation Script -->
<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
<script>
  AOS.init();
</script>

<!-- Navbar Scroll Effect -->
<script>
  window.addEventListener('scroll', () => {
    const navbar = document.querySelector('.navbar');
    if (window.scrollY > 50) {
      navbar.classList.add('scrolled');
    } else {
      navbar.classList.remove('scrolled');
    }
  });
</script>

<!-- About Section Tabbed Interface Script -->
<script>
  document.querySelectorAll('.about-tab').forEach(tab => {
    tab.addEventListener('click', () => {
      // Remove active class from all tabs and contents
      document.querySelectorAll('.about-tab').forEach(t => t.classList.remove('active'));
      document.querySelectorAll('.about-content').forEach(c => c.classList.remove('active'));

      // Add active class to clicked tab and corresponding content
      tab.classList.add('active');
      document.getElementById(tab.dataset.tab).classList.add('active');
    });
  });
</script>
</body>
</html>