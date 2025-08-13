/**
* the logger object
*/
global class Logger {
    /**
    * the time object
    */
    global class Timex {
        public final Long start = Datetime.now().getTime();
        public final String message;
        global Timex() { }
        global Timex(String message) { this.message = message; }
        global override String toString() { Datetime d = Datetime.newInstance(Datetime.now().getTime() - (Long)start); return d.formatGmt(d.hour() == 0 ? 'mm:ss.SSS' : 'HH:mm:ss.SSS'); }
    }

    global List<String> logs = new List<String>();

    global void add(String message) { logs.add(message); }

    global String clear() { String r = String.join(logs, '\n'); logs.clear(); return r; }

    global void log(LoggingLevel level, String message)                                             { log(null, level, '', null, message); }
    global void log(LoggingLevel level, String message, Object[] args)                              { log(null, level, '', null, String.format(message, args)); }
    global void log(LoggingLevel level, String eventId, String message)                             { log(null, level, eventId, null, message); }
    global void log(LoggingLevel level, String eventId, String message, Object[] args)              { log(null, level, eventId, null, String.format(message, args)); }
    global void log(LoggingLevel level, Exception ex, String message)                               { log(null, level, '', ex, message); }
    global void log(LoggingLevel level, Exception ex, String message, Object[] args)                { log(null, level, '', ex, String.format(message, args)); }
    global void log(LoggingLevel level, String eventId, Exception ex, String message)               { log(null, level, eventId, ex, message); }
    global void log(LoggingLevel level, String eventId, Exception ex, String message, Object[] args){ log(null, level, eventId, ex, String.format(message, args)); }
    global void log(Object obj, String message)                                                     { log(obj, LoggingLevel.NONE, '', null, message); }
    global void log(Object obj, String message, Object[] args)                                      { log(obj, LoggingLevel.NONE, '', null, String.format(message, args)); }
    global void log(Object obj, String eventId, String message)                                     { log(obj, LoggingLevel.NONE, eventId, null, message); }
    global void log(Object obj, String eventId, String message, Object[] args)                      { log(obj, LoggingLevel.NONE, eventId, null, String.format(message, args)); }
    global void log(Object obj, Exception ex, String message)                                       { log(obj, LoggingLevel.NONE, '', ex, message); }
    global void log(Object obj, Exception ex, String message, Object[] args)                        { log(obj, LoggingLevel.NONE, '', ex, String.format(message, args)); }
    global void log(Object obj, String eventId, Exception ex, String message)                       { log(obj, LoggingLevel.NONE, eventId, ex, message); }
    global void log(Object obj, String eventId, Exception ex, String message, Object[] args)        { log(obj, LoggingLevel.NONE, eventId, ex, String.format(message, args)); }
    global void log(Object obj, LoggingLevel level, String eventId, Exception ex, String message)   {
        if (obj instanceof Timex) {
            Timex s = (Timex)obj;
            eventId = s.toString() + (eventId != null ? ':' + eventId : '');
            message = (s.message != null ? s.message + ':' : '') + (message ?? '');
        }
        message = (level != LoggingLevel.NONE ? level.name().substring(0, 3) : '') + (String.isNotEmpty(eventId) ? '[' + eventId + ']' : '') + ' | ' + (message ?? '');
        if (ex != null) message += (String.isNotEmpty(message) ? '\n' : '') + ex.getMessage() + '\n' + ex.getStackTraceString();
        logs.add(message);
    }
    global void logDebug(String message)                                                            { log(null, LoggingLevel.DEBUG, '', null, message); }
    global void logDebug(String message, Object[] args)                                             { log(null, LoggingLevel.DEBUG, '', null, String.format(message, args)); }
    global void logDebug(String eventId, String message)                                            { log(null, LoggingLevel.DEBUG, eventId, null, message); }
    global void logDebug(String eventId, String message, Object[] args)                             { log(null, LoggingLevel.DEBUG, eventId, null, String.format(message, args)); }
    global void logDebug(Exception ex, String message)                                              { log(null, LoggingLevel.DEBUG, '', ex, message); }
    global void logDebug(Exception ex, String message, Object[] args)                               { log(null, LoggingLevel.DEBUG, '', ex, String.format(message, args)); }
    global void logDebug(String eventId, Exception ex, String message)                              { log(null, LoggingLevel.DEBUG, eventId, ex, message); }
    global void logDebug(String eventId, Exception ex, String message, Object[] args)               { log(null, LoggingLevel.DEBUG, eventId, ex, String.format(message, args)); }
    global void logError(String message)                                                            { log(null, LoggingLevel.ERROR, '', null, message); }
    global void logError(String message, Object[] args)                                             { log(null, LoggingLevel.ERROR, '', null, String.format(message, args)); }
    global void logError(String eventId, String message)                                            { log(null, LoggingLevel.ERROR, eventId, null, message); }
    global void logError(String eventId, String message, Object[] args)                             { log(null, LoggingLevel.ERROR, eventId, null, String.format(message, args)); }
    global void logError(Exception ex, String message)                                              { log(null, LoggingLevel.ERROR, '', ex, message); }
    global void logError(Exception ex, String message, Object[] args)                               { log(null, LoggingLevel.ERROR, '', ex, String.format(message, args)); }
    global void logError(String eventId, Exception ex, String message)                              { log(null, LoggingLevel.ERROR, eventId, ex, message); }
    global void logError(String eventId, Exception ex, String message, Object[] args)               { log(null, LoggingLevel.ERROR, eventId, ex, String.format(message, args)); }
    global void logFine (String message)                                                            { log(null, LoggingLevel.FINE, '', null, message); }
    global void logFine (String message, Object[] args)                                             { log(null, LoggingLevel.FINE, '', null, String.format(message, args)); }
    global void logFine (String eventId, String message)                                            { log(null, LoggingLevel.FINE, eventId, null, message); }
    global void logFine (String eventId, String message, Object[] args)                             { log(null, LoggingLevel.FINE, eventId, null, String.format(message, args)); }
    global void logFine (Exception ex, String message)                                              { log(null, LoggingLevel.FINE, '', ex, message); }
    global void logFine (Exception ex, String message, Object[] args)                               { log(null, LoggingLevel.FINE, '', ex, String.format(message, args)); }
    global void logFine (String eventId, Exception ex, String message)                              { log(null, LoggingLevel.FINE, eventId, ex, message); }
    global void logFine (String eventId, Exception ex, String message, Object[] args)               { log(null, LoggingLevel.FINE, eventId, ex, String.format(message, args)); }
    global void logFiner(String message)                                                            { log(null, LoggingLevel.FINER, '', null, message); }
    global void logFiner(String message, Object[] args)                                             { log(null, LoggingLevel.FINER, '', null, String.format(message, args)); }
    global void logFiner(String eventId, String message)                                            { log(null, LoggingLevel.FINER, eventId, null, message); }
    global void logFiner(String eventId, String message, Object[] args)                             { log(null, LoggingLevel.FINER, eventId, null, String.format(message, args)); }
    global void logFiner(Exception ex, String message)                                              { log(null, LoggingLevel.FINER, '', ex, message); }
    global void logFiner(Exception ex, String message, Object[] args)                               { log(null, LoggingLevel.FINER, '', ex, String.format(message, args)); }
    global void logFiner(String eventId, Exception ex, String message)                              { log(null, LoggingLevel.FINER, eventId, ex, message); }
    global void logFiner(String eventId, Exception ex, String message, Object[] args)               { log(null, LoggingLevel.FINER, eventId, ex, String.format(message, args)); }
    global void logFinest(String message)                                                           { log(null, LoggingLevel.FINEST, '', null, message); }
    global void logFinest(String message, Object[] args)                                            { log(null, LoggingLevel.FINEST, '', null, String.format(message, args)); }
    global void logFinest(String eventId, String message)                                           { log(null, LoggingLevel.FINEST, eventId, null, message); }
    global void logFinest(String eventId, String message, Object[] args)                            { log(null, LoggingLevel.FINEST, eventId, null, String.format(message, args)); }
    global void logFinest(Exception ex, String message)                                             { log(null, LoggingLevel.FINEST, '', ex, message); }
    global void logFinest(Exception ex, String message, Object[] args)                              { log(null, LoggingLevel.FINEST, '', ex, String.format(message, args)); }
    global void logFinest(String eventId, Exception ex, String message)                             { log(null, LoggingLevel.FINEST, eventId, ex, message); }
    global void logFinest(String eventId, Exception ex, String message, Object[] args)              { log(null, LoggingLevel.FINEST, eventId, ex, String.format(message, args)); }
    global void logInfo (String message)                                                            { log(null, LoggingLevel.INFO, '', null, message); }
    global void logInfo (String message, Object[] args)                                             { log(null, LoggingLevel.INFO, '', null, String.format(message, args)); }
    global void logInfo (String eventId, String message)                                            { log(null, LoggingLevel.INFO, eventId, null, message); }
    global void logInfo (String eventId, String message, Object[] args)                             { log(null, LoggingLevel.INFO, eventId, null, String.format(message, args)); }
    global void logInfo (Exception ex, String message)                                              { log(null, LoggingLevel.INFO, '', ex, message); }
    global void logInfo (Exception ex, String message, Object[] args)                               { log(null, LoggingLevel.INFO, '', ex, String.format(message, args)); }
    global void logInfo (String eventId, Exception ex, String message)                              { log(null, LoggingLevel.INFO, eventId, ex, message); }
    global void logInfo (String eventId, Exception ex, String message, Object[] args)               { log(null, LoggingLevel.INFO, eventId, ex, String.format(message, args)); }
    global void logWarn(String message)                                                             { log(null, LoggingLevel.WARN, '', null, message); }
    global void logWarn(String message, Object[] args)                                              { log(null, LoggingLevel.WARN, '', null, String.format(message, args)); }
    global void logWarn(String eventId, String message)                                             { log(null, LoggingLevel.WARN, eventId, null, message); }
    global void logWarn(String eventId, String message, Object[] args)                              { log(null, LoggingLevel.WARN, eventId, null, String.format(message, args)); }
    global void logWarn(Exception ex, String message)                                               { log(null, LoggingLevel.WARN, '', ex, message); }
    global void logWarn(Exception ex, String message, Object[] args)                                { log(null, LoggingLevel.WARN, '', ex, String.format(message, args)); }
    global void logWarn(String eventId, Exception ex, String message)                               { log(null, LoggingLevel.WARN, eventId, ex, message); }
    global void logWarn(String eventId, Exception ex, String message, Object[] args)                { log(null, LoggingLevel.WARN, eventId, ex, String.format(message, args)); }


    global override String toString() { return String.join(logs, '\n'); }
}