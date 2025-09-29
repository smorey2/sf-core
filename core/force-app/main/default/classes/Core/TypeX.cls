/**
* Type method extensions
*/
global class TypeX {
    /**
    * gets the type that corresponds to the class name.
    * @param clsName the class name
    * @return Type
    */
    global static Type forName(String clsName) {
        return Type.forName(null, clsName) ?? Type.forName(clsName);
    }

    /**
    * decodes an object
    * @param value the value
    * @return Object
    */
    global static Object decode(String value) {
        String name = value.substring(0, value.indexOf(':')), body = value.substring(value.indexOf(':') + 1);
        Type type = TypeX.forName(name);
        return JSON.deserialize(body, type);
    }

    /**
    * encodes an object
    * @param type the Type of value
    * @param value the value
    * @return String
    */
    global static String encode(Type type, Object value) {
        return type.getName() + ':' + JSON.serialize(value);
    }
}