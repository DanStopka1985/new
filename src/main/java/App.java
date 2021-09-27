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
                             db.prepareStatement("" +

                                     "select sname, fname, mname, bdate, g.name, snils.code from indiv i\n" +
                                     "join gender g on g.id = i.gender_id\n" +
                                     "join indiv_code snils on snils.indiv_id = i.id and snils.type_id in (select id from indiv_code_type where code = 'SNILS')\n" +
                                     "order by snils.code limit 30"

                             ))
                {
                    ResultSet rs = query.executeQuery();
                    while (rs.next()) {
                        //System.out.println(String.format("%s, %s!", rs.getString(1), rs.getString(2)));
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
}
