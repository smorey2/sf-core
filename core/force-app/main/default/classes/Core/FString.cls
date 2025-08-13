/**
* a FString for Dictionary<String, Object> representation in flows
*/
global class FString {
	/**
	* the flow input
	*/
    global class Input {
		@InvocableVariable(label='Operation' description='The operation to preform' required=true) global String Operation;
		@InvocableVariable(label='Source' description='The source FString') global FString Source;
		@InvocableVariable(label='Key' description='The key to use') global String Key;
		@InvocableVariable(label='Value' description='The value to use') global List<FString> Value;
    }

	/**
	* the flow output
	*/
	global class Output {
		@InvocableVariable(label='Source' description='The source FString') global FString Source;
    }

	@AuraEnabled global String Key;
	@AuraEnabled global String S;
	@AuraEnabled global Boolean B;
	@AuraEnabled global Integer I;
	@AuraEnabled global Long L;
	@AuraEnabled global Double D;
	@AuraEnabled global Date Y;
	@AuraEnabled global Datetime Z;
	@AuraEnabled global Object O;

    /**
    * invokable preforms an action on a StringXAura
    * @param inputs the flow inputs
    * @return List<Output>
    */
    @InvocableMethod(label='core: FString action'
		iconName='slds:standard:choice'
		description='Performs an action on a FString.'
		category='Task')
	global static List<Output> execute(List<Input> inputs) {
		List<Output> r = new List<Output>();
		for (Input s : inputs) {
			Output o = new Output();
			if (s.Source == null) s.Source = new FString();
			if (s.Source.O == null && s.Operation == 'Add') { s.Source.Key = s.Key; s.Source.O = new List<List<FString>>(); }
			switch on s.Operation {
				when 'Add' { ((List<List<FString>>)s.Source.O).add(s.Value); }
				when 'Set' { s.Source.Key = s.Key; s.Source.O = s.Value; }
				when 'Debug' { SystemX.debug(s.Source); }
				when else { throw new HandledException('Unknown Operation: ' + s.Operation); }
			}
			o.Source = s.Source;
			r.add(o);
		}
		return r;
    }

    /**
    * decodes an aura map
    * @param value the value
    * @param lower the make keys lowercase
    * @return List<FString>
    */
    global static List<FString> decodeMap(String values, Boolean lower) {
        if (String.isEmpty(values)) return null;
        List<FString> r = new List<FString>();
        for (String value : values.split(',')) {
            String type = value.substring(0, 1), key = value.substring(1, value.indexOf('=')), str = value.substring(value.indexOf('=') + 1);
            if (lower) key = key.toLowerCase();
            FString s = new FString();
            switch on type {
                when 's' { s.key = 's' + key; s.S = str; }
                when 'b' { s.key = 'b' + key; s.B = Boolean.valueOf(str); }
                when 'i' { s.key = 'i' + key; s.I = Integer.valueOf(str); }
                when 'l' { s.key = 'l' + key; s.L = Long.valueOf(str); }
                when 'd' { s.key = 'd' + key; s.D = Double.valueOf(str); }
                when 'y' { s.key = 'y' + key; s.Y = Date.valueOf(str); }
                when 'z' { s.key = 'z' + key; s.Z = Datetime.valueOfGmt(str); }
                when 'o' {
                    s.key = 'o' + key;
                    Object o;
                    if (str.startsWith('{') && str.endsWith('}')) {
                        str = str.substring(1, str.length() - 1).replaceAll('`', ',');
                        o = decodeMap(str, lower);
                    }
                    else if (str == '[]') o = new List<List<FString>>();
                    else if (str.startsWith('[{') && str.endsWith('}]')) {
                        str = str.substring(2, str.length() - 2);
                        List<List<FString>> b2 = new List<List<FString>>();
                        for (String values2 : str.split('\\}`\\{')) b2.add(decodeMap(values2, lower));
                        o = b2;
                    }
                    else throw new HandledException('Unknown object: ' + str);
                    s.O = o;
                }
                when else { throw new HandledException('Unknown type for: ' + type + key); }
            }
            r.add(s);
        }
        return r;
    }

    /**
    * decodes an aura map
    * @param value the value
    * @param lower the make keys lowercase
    * @return Map<String, Object>
    */
    global static Map<String, Object> decodeMap(List<FString> values, Boolean lower) {
        if (values == null || values.size() == 0) return null;
        Map<String, Object> r = new Map<String, Object>();
        for (FString s : values) {
            String type = s.Key.substring(0, 1), key = s.Key.substring(1), str = s.S;
            if (lower) key = key.toLowerCase();
            switch on type {
                when 's' { r.put(key, s.S); }
                when 'b' { r.put(key, s.B); }
                when 'i' { r.put(key, s.I); }
                when 'l' { r.put(key, s.L); }
                when 'd' { r.put(key, s.D); }
                when 'y' { r.put(key, s.Y); }
                when 'z' { r.put(key, s.Z); }
                when 'o' {
                    Object o;
                    if (s.O instanceOf List<FString>) o = decodeMap((List<FString>)s.O, lower);
                    else if (s.O instanceOf List<List<FString>>) {
                        List<Map<String, Object>> b2 = new List<Map<String, Object>>();
                        for (List<FString> s2 : (List<List<FString>>)s.O) b2.add(decodeMap(s2, lower));
                        o = b2;
                    }
                    else if (String.isEmpty(str)) throw new HandledException('Unknown object: ' + s.O);
                    else if (str.startsWith('{') && str.endsWith('}')) {
                        str = str.substring(1, str.length() - 1).replaceAll('`', ',');
                        o = StringX.decodeMap(str, lower);
                    }
                    else if (str == '[]') o = new List<Map<String, Object>>();
                    else if (str.startsWith('[{') && str.endsWith('}]')) {
                        str = str.substring(2, str.length() - 2);
                        List<Map<String, Object>> b2 = new List<Map<String, Object>>();
                        for (String values2 : str.split('\\}`\\{')) b2.add(StringX.decodeMap(values2, lower));
                        o = b2;
                    }
                    else throw new HandledException('Unknown object: ' + str);
                    r.put(key, o);
                }
                when else { throw new HandledException('Unknown type for: ' + type + key); }
            }
        }
        return r;
    }

    /**
    * encodes an aura map
    * @param values the values
    * @param lower the make keys lowercase
    * @return List<FString>
    */
    global static List<FString> encodeMap(Map<String, Object> values, Boolean lower) {
        if (values == null) return null;
        List<FString> r = new List<FString>();
        for (String key : values.keySet()) {
            FString s = new FString();
            Object value = values.get(key);
            if (value == null) s.Key = 's' + key;
            else if (value instanceOf String) { s.Key = 's' + key; s.S = (String)value;  }
            else if (value instanceOf Boolean) { s.Key = 'b' + key; s.B = (Boolean)value; }
            else if (value instanceOf Integer) { s.Key = 'i' + key; s.I = (Integer)value; }
            else if (value instanceOf Long) { s.Key = 'l' + key; s.L = (Long)value; }
            else if (value instanceOf Double || value instanceOf Decimal) { s.Key = 'd' + key; s.D = (Double)value;}
            else if (value instanceOf Date) { s.Key = 'y' + key; s.Y = (Date)value; }
            else if (value instanceOf Datetime) { s.Key = 'z' + key; s.Z = (DateTime)value; }
            else if (value instanceOf Map<String, Object> || value instanceOf List<Map<String, Object>>) {
                Object o;
                if (value instanceOf Map<String, Object>) o = encodeMap((Map<String, Object>)value, lower);
                else if (value instanceOf List<Map<String, Object>>) {
                    List<List<FString>> b2 = new List<List<FString>>();
                    for (Map<String, Object> s2 : (List<Map<String, Object>>)value) b2.add(encodeMap(s2, lower));
                    o = b2;
                }
                s.Key = 'o' + key; s.O = o;
            }
            else { throw new HandledException('Unknown type for: ' + key); }
            r.add(s);
        }
        return r;
    }

    /**
    * encodes an aura map
    * @param values the values
    * @param lower the make keys lowercase
    * @return String
    */
    global static String encodeMap(List<FString> values, Boolean lower) {
        if (values == null) return null;
        List<String> r = new List<String>();
        for (FString s : values) {
            String type = s.Key.substring(0, 1), key = s.Key.substring(1);
            switch on type {
                when 's' { r.add('s' + key + '=' + s.S); }
                when 'b' { r.add('b' + key + '=' + String.valueOf(s.B)); }
                when 'i' { r.add('i' + key + '=' + String.valueOf(s.I)); }
                when 'l' { r.add('l' + key + '=' + String.valueOf(s.L)); }
                when 'd' { r.add('d' + key + '=' + String.valueOf(s.D)); }
                when 'y' { r.add('y' + key + '=' + String.valueOf(s.Y).removeEnd(' 00:00:00')); }
                when 'z' { r.add('z' + key + '=' + String.valueOfGmt(s.Z)); }
                when 'o' {
                    String str;
                    if (s.O instanceOf List<FString>) str = '{' + encodeMap((List<FString>)s.O, lower).replaceAll(',', '`') + '}';
                    else if (s.O instanceOf List<List<FString>>) {
                        List<String> b2 = new List<String>();
                        for (List<FString> s2 : (List<List<FString>>)s.O) b2.add('{' + encodeMap(s2, lower).replaceAll(',', '`') + '}');
                        str = '[' + String.join(b2, '`') + ']';
                    }
                    else throw new HandledException('Unknown object: ' + s.O);
                    r.add('o' + key + '=' + str);
                }
                when else { throw new HandledException('Unknown type for: ' + type + key); }
            }
        }
        return String.join(r, ',');
    }
}
