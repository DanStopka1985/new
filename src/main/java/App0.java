import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.concurrent.CountDownLatch;
import java.util.stream.IntStream;
//очистить лог бд
//рассказ вкратце про хикари
//Сэмулируем запуск самого простого запроса 200ми условными пользователями. -> запустить

public final class App0 {
    private static final Integer NO_THREADS = 200;
    private App0() {
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
                             db.prepareStatement("select  ;"))
                {
                    ResultSet rs = query.executeQuery();
                    while (rs.next()) {
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
//Выполнение происходит мгновенно
//Посмотрим лог БД
//Как видно - читать и анализировать лог простым просмотром не очень удобно, особенно на реальных данных.
//Чтобы анализировать лог будем использовать анализатор лога pgbadger.
//Запустить генерацию отчета pgbadger create.bat
//В отчете удобно смотреть самые долгие запросы, самые частые, самые долгие суммарно и т.д.
//Так как лог пустой, наш “select” – самый долгий запрос. Он занимает все позиции top 20 slowest individual queries.
// Так же можно посмотреть топ суммарных выполнений одинаковых запросов.
// Наш запрос так же на первом месте, количество запусков 200 как и планировалось. Здесь оптимизировать нечего.


//Теперь напишем запрос по поиску индивида по СНИЛС
/* 1_find_indiv_by_snils.sql */