package util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

public class DatabaseConnection {
    private static final Properties properties = new Properties();
    private static String url;
    private static String username;
    private static String password;

    static {
        try {
            // Load database properties
            InputStream input = DatabaseConnection.class.getClassLoader().getResourceAsStream("db.properties");
            if (input == null) {
                throw new RuntimeException("Unable to find db.properties");
            }
            properties.load(input);

            // Get database connection properties
            url = properties.getProperty("db.url");
            username = properties.getProperty("db.username");
            password = properties.getProperty("db.password");

            // Load MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");

        } catch (IOException | ClassNotFoundException e) {
            throw new RuntimeException("Database initialization failed. Please check:\n" +
                    "1. MySQL server is running\n" +
                    "2. MySQL connector JAR is in classpath\n" +
                    "3. Connection parameters in db.properties are correct\n" +
                    "4. Database exists and user has permissions", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, username, password);
    }

    private static void loadDatabaseConfig() throws IOException {
        try (InputStream input = DatabaseConnection.class.getClassLoader()
                .getResourceAsStream("db.properties")) {

            if (input == null) {
                throw new RuntimeException("db.properties file not found in classpath");
            }
            properties.load(input);

            // Validate required properties
            if (properties.getProperty("db.url") == null ||
                    properties.getProperty("db.username") == null) {
                throw new RuntimeException("Missing required database properties");
            }
        }
    }

    private static void initializeDatabase() throws SQLException, IOException {
        try (Connection conn = getConnection();
                Statement stmt = conn.createStatement()) {

            // Check if schema.sql exists
            try (InputStream input = DatabaseConnection.class.getClassLoader()
                    .getResourceAsStream("schema.sql")) {

                if (input == null) {
                    System.err.println("Warning: schema.sql not found - skipping initialization");
                    return;
                }

                // Execute schema script
                executeSchemaScript(stmt, input);
            }
        }
    }

    private static void executeSchemaScript(Statement stmt, InputStream input)
            throws IOException, SQLException {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(input))) {
            StringBuilder command = new StringBuilder();
            String line;

            while ((line = reader.readLine()) != null) {
                line = line.trim();

                // Skip comments and empty lines
                if (line.isEmpty() || line.startsWith("--")) {
                    continue;
                }

                command.append(line);

                // Execute complete statements
                if (line.endsWith(";")) {
                    try {
                        stmt.execute(command.toString());
                    } catch (SQLException e) {
                        System.err.println("Error executing: " + command);
                        throw e;
                    }
                    command.setLength(0);
                }
            }
        }
    }

    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                if (!conn.isClosed()) {
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("Error closing connection: " + e.getMessage());
            }
        }
    }
}