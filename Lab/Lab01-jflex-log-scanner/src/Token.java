/** One token: its kind, the exact text matched, and where it starts (1-based). */
public class Token {
    public final TokenType type;
    public final String text;
    public final int line;
    public final int column;
    public final String message;   // only set for ERROR tokens

    public Token(TokenType type, String text, int line, int column, String message) {
        this.type = type;
        this.text = text;
        this.line = line;
        this.column = column;
        this.message = message;
    }

    @Override
    public String toString() {
        String pos = String.format("%3d:%-3d", line, column);
        if (type == TokenType.ERROR) return pos + " ERROR      " + message;
        if (type == TokenType.EOF)   return pos + " EOF";
        return String.format("%s %-10s %s", pos, type, text);
    }
}
