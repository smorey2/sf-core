global virtual class GrammerX {
    // https://developer.salesforce.com/docs/marketing/marketing-cloud/guide/using_regular_expressions_to_validate_email_addresses.html
    // global static final Pattern EmailPattern        = Pattern.compile('(?i)^[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$');
    global static final Pattern EmailPattern        = Pattern.compile('(?i)^[-a-z0-9!#$%&\'*+/=?^_`{|}~]+(?:\\.[-a-z0-9!#$%&\'*+/=?^_`{|}~]+)*@(?:[a-z0-9](?:[-a-z0-9]*[a-z0-9])?\\.)+[a-z0-9](?:[-a-z0-9]*[a-z0-9])?$');
    global static final Pattern InvalidEmailPattern = Pattern.compile('(?i)[^-a-z0-9!#$%&\'*+/=?^_`{|}~.@]');
    
    /**
    * validates an email
    * @param email the email
    * @return Boolean
    */
    global static Boolean validEmail(String email) { return EmailPattern.matcher(email).matches(); }

    /**
    * cleans an email
    * @param email the email
    * @return String
    */
    global static String cleanEmail(String email) { return InvalidEmailPattern.matcher(email).replaceAll(''); }

    /**
    * ensures an email
    * @param email the email
    * @param name the name
    * @return String
    */
    global virtual String ensureEmail(String email, String name) { return String.isEmpty(email) ? makeBadEmail(name) : EmailPattern.matcher(email).matches() ? email : makeBadEmail(name); }

    /**
    * makes a bad email
    * @param name the name
    * @return String
    */
    global virtual String makeBadEmail(String name) { return cleanEmail(name.toLowerCase().trim().replace(' ', '.').replace('..', '.') + '@bademail.com'); }
}