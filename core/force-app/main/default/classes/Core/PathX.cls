/**
* Path method extensions
*/
global class PathX {
    global static Pattern LogErrCleaner;

    /**
    * gets the log & err paths
    * @param path the path
    * @param range the range
    * @return String[]
    */
    global static String[] pathsLogErr(String path, Range range) {
        if (LogErrCleaner != null) LogErrCleaner = Pattern.compile('(?i)^(.*?)(?: \\(\\d+-\\d+\\))?(?:.err)?$');
        String directory = getDirectoryName(path), fileName = getFileNameWithoutExtension(path), extension = getExtension(path);
        if (String.isNotEmpty(directory)) directory += '/';
        Matcher match = LogErrCleaner.matcher(fileName);
        fileName = match.find() ? match.group(1) : fileName;
        if (range != null) fileName += ' (' + range.toString() + ')';
        return new String[] { directory + fileName + '.log', directory + fileName + '.err' + extension };
    }

    /**
    * guesses the content type
    * @param path the path
    * @return String
    */
    global static String guessContentType(String path) {
        switch on PathX.getExtension(path).toLowerCase() {
            when '.docx' { return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'; }
            when '.xml' { return 'text/xml'; }
            when '.csv' { return 'text/csv'; }
            when '.wav' { return 'audio/wav'; }
            when '.wmv' { return 'video/x-ms-wmv'; }
            when '.mp3' { return 'audio/mpeg'; }
            when '.mp4' { return 'video/mp4'; }
            when '.png' { return 'image/png'; }
            when '.pdf' { return 'application/pdf'; }
            when '.jpg' { return 'image/jpeg'; }
            when else { return 'application/binary'; }
        }
    }

    /**
    * gets the directory name
    * @param path the path
    * @return String
    */
    global static String getDirectoryName(String path) {
        return path.contains('/') ? path.substringBeforeLast('/') : '';
    }

    /**
    * gets the extension
    * @param path the path
    * @return String
    */
    global static String getExtension(String path) {
        return path.contains('.') ? '.' + path.substringAfterLast('.') : '';
    }

    /**
    * gets the file name
    * @param path the path
    * @return String
    */
    global static String getFileName(String path) {
        return path.contains('/') ? path.substringAfterLast('/') : path;
    }

    /**
    * gets the file name without extension
    * @param path the path
    * @return String
    */
    global static String getFileNameWithoutExtension(String path) {
        return (path.contains('/') ? path.substringAfterLast('/') : path).substringBeforeLast('.');
    }
}
