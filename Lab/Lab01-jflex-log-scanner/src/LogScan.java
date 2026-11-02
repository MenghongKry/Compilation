import java.io.BufferedReader;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.StringReader;

/**
 * Lists the tokens of log lines. It only scans; it does not interpret the log.
 *
 *   java -cp build LogScan file.log      scan a whole file
 *   java -cp build LogScan               interactive: scan each line you type
 *   echo '[INFO] code=200' | java -cp build LogScan
 */
public class LogScan {

    public static void main(String[] args) throws Exception {
        if (args.length > 0) {
            try (Reader in = new BufferedReader(new FileReader(args[0]))) {
                scan(in);
            }
            return;
        }
        if (System.console() == null) {           // piped input: scan it all at once
            scan(new BufferedReader(new InputStreamReader(System.in)));
            return;
        }
        System.out.println("JFlex Log Scanner - type a log line to see its tokens.");
        System.out.println("Format: YYYY-MM-DD hh:mm:ss [LEVEL] field=value ...   Type 'quit' or Ctrl+D to exit.");
        BufferedReader console = new BufferedReader(new InputStreamReader(System.in));
        while (true) {
            System.out.print("> ");
            String line = console.readLine();
            if (line == null || line.trim().equals("quit")) break;
            scan(new StringReader(line));
        }
    }

    /** Prints every token, then a summary line. */
    static void scan(Reader in) throws java.io.IOException {
        Lexer lexer = new Lexer(in);
        int tokens = 0, errors = 0;
        System.out.println("LINE:COL TYPE       LEXEME");
        Token t;
        do {
            t = lexer.yylex();
            System.out.println(t);
            if (t.type == TokenType.ERROR) errors++;
            else if (t.type != TokenType.EOF) tokens++;
        } while (t.type != TokenType.EOF);
        System.out.println(tokens + " token(s), " + errors + " error(s)");
    }
}
