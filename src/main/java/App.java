import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.concurrent.CountDownLatch;
import java.util.stream.IntStream;
public final class App {
    private static final Integer NO_THREADS = 200;
    private App() {
    }

    public static void main(final String[] args) throws InterruptedException {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(
                "jdbc:postgresql://127.0.0.1/test?user=postgres&password=postgres");
        config.setConnectionTimeout(60000);
        HikariDataSource ds = new HikariDataSource(config);


        CountDownLatch startLatch = new CountDownLatch(NO_THREADS);
        CountDownLatch finishLatch = new CountDownLatch(NO_THREADS);

        Runnable readingThread = () -> {
            String code = getRandomCode(ds);
            startLatch.countDown();
            try {
                startLatch.await();
            } catch (InterruptedException ex) {
                System.out.println("Synchronization failure: "
                        + ex.getMessage());
                return;
            }

            try (Connection db = ds.getConnection()) {
                try (PreparedStatement query =
                             db.prepareStatement("select i.sname from indiv i where id = (select id from indiv_code where code = ?)"
                             ))
                {
                    query.setString(1, code);
                    ResultSet rs = query.executeQuery();
                    while (rs.next()) {
                        System.out.println(rs.getString(1));
                    }
                    rs.close();
                }
            } catch (SQLException ex) {
                System.out.println("Database connection failure: "
                        + ex.getMessage());
            }



            finishLatch.countDown();
        };

        IntStream.range(0, NO_THREADS).forEach(
                (index) -> new Thread(readingThread).start()
        );

        finishLatch.await();
        System.out.println("All reading thread complete.");

    }


    private static String getRandomCode(HikariDataSource ds){
        String code = "";
        try (Connection db = ds.getConnection()) {
            try (PreparedStatement query =
                         db.prepareStatement("select code from indiv_code where id = (select (random() * max(id))::int from indiv_code)"
                         ))
            {
                ResultSet rs = query.executeQuery();
                while (rs.next()) {
                    code = rs.getString(1);
                }
                rs.close();
            }
        } catch (SQLException ex) {
            System.out.println("Database connection failure: "
                    + ex.getMessage());
        }
        return code;
    }
}
