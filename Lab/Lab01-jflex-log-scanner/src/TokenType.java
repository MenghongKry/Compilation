/** Every kind of token the scanner can produce. */
public enum TokenType {
    TIMESTAMP,  // 2026-11-02 08:15:00
    LEVEL,      // DEBUG, INFO, WARN, ERROR
    FIELD,      // code, message, user_id
    ASSIGN,     // =
    INTEGER,    // 200
    MESSAGE,    // "Ready"
    LBRACKET,   // [
    RBRACKET,   // ]
    ERROR,      // invalid input (the scanner reports it and keeps going)
    EOF         // end of input
}
