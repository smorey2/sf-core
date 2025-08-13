/**
* DefaultOptions
*/
global virtual class DefaultOptions {
    /**
    * writes to the execution debug log
    * @param logLevel the logLevel
    * @param msg the message
    */
    global virtual void debug(LoggingLevel logLevel, Object msg) { System.debug(logLevel, msg); }

    /**
    * untypes object
    * @param obj the obj
    * @return Map<String, Object>
    */
    global virtual Map<String, Object> untype(Object obj) { return (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj, true)); }

    /**
    * gets the service user
    * @param type the type
    * @return String
    */
    global virtual String serviceUserAlias(String type) { return null; }

    /**
    * funcs the object
    * @param s the object
    * @param name the name
    * @return Object
    */
    global virtual Object funcValue(Object s, String name) {
        String func = name.substringBefore(':'), arg = name.substringAfter(':');
        switch on func {
            when 'default' { return String.isNotEmpty((String)s) ? (String)s : arg; }
            when 'clamp' { return StringX.clamp((String)s, Integer.valueOf(arg)); }
            when 'multi' { return ((String)s)?.split(';'); }
            when 'lowercase' { return ((String)s)?.toLowerCase(); }
            when 'datetime' { return ((Datetime)s)?.format(arg); } // datetime:yyyy-MM-dd'T'HH:mm:ss'Z'
            when 'case' { // case:Fulfilled|shipped;Delivered|delivered;*|processing
                arg = ';' + arg;
                String item = arg.substringAfter(';' + (String)s + '|').substringBefore(';');
                if (String.isEmpty(item)) item = arg.substringAfter(';*|').substringBefore(';');
                if (String.isEmpty(item)) item = (String)s;
                return item;
            }
            when else { return s; }
        }
    }

    /**
    * funcs the flobal
    * @param name the name
    * @return Object
    */
    global virtual Object funcGlobal(String name) {
        switch on name {
            when 'now' { return Datetime.now(); }
            when else { throw new HandledException('Uknown global: ' + name); }
        }
    }
}