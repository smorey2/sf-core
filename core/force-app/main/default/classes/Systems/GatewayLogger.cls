/**
* the gateway logger
*/
global abstract class GatewayLogger {
    global final Map<Schema.SObjectType, String> related = makeRelated();
    global final Map<Field, String> fields = makeFields();
    global final SObject log = createLog();
    global Integer level = 0;
    global Boolean debugBuild;

    /**
    * the field types
    */
    global enum Field {
        InteractionType,
        GatewayMessage,
        ErrorMessage,
        Request,
        Response,
        ResultCode
    }

    global virtual Map<Schema.SObjectType, String> makeRelated() { return new Map<Schema.SObjectType, String> { }; }
    
    global virtual Map<Field, String> makeFields() {
        return new Map<Field, String> {
            Field.InteractionType => 'InteractionType__c',
            Field.GatewayMessage => 'GatewayMessage__c',
            Field.ErrorMessage => 'ErrorMessage__c',
            Field.Request => 'Request__c',
            Field.Response => 'Response__c',
            Field.ResultCode => 'ResultCode__c'
        };
    }

    global abstract SObject createLog();

    /**
    * sets level
    * @param level the level
    * @return GatewayLogger
    */
    global GatewayLogger level(Integer level) { this.level = level; return this; }

    /**
    * includes a value
    * @param field the field
    * @param length the field length
    * @param value the value
    * @return GatewayLogger
    */
    global GatewayLogger value(String field, Integer length, String value) {
        if (value == null || !String.isNotBlank(value)) return this;
        log.put(field, StringX.clamp(value, length));
        return this;
    }

    /**
    * includes a value
    * @param field the field
    * @param value the value
    * @return GatewayLogger
    */
    global virtual GatewayLogger value(String field, Object value) {
        if (value == null) return this;
        log.put(field, value);
        return this;
    }

    /**
    * sets interaction type
    * @param interactionType the interaction type
    * @return GatewayLogger
    */
    global GatewayLogger interactionType(String interactionType) {
        if (interactionType == null) return this;
        log.put(fields.get(Field.InteractionType), interactionType);
        return this;
    }

    /**
    * sets related to
    * @param relatedToId the related to Id
    * @return GatewayLogger
    */
    global GatewayLogger relatedTo(Id relatedToId) {
        if (relatedToId == null) return this;
        String field = related.get(relatedToId.getSobjectType());
        if (field != null) log.put(field, relatedToId);
        return this;
    }

    /**
    * builds the log without inserting
    * @return SObject
    */
    global SObject build() {
        if (debugBuild == true) SystemX.debug(toString());
        return log;
    }

    /**
    * builds the log with inserting
    * @return SObject
    */
    global SObject buildAndLog() {
        if (debugBuild == true) SystemX.debug(toString());
        Database.insert(log);
        return log;
    }

    /**
    * includes the gateway message
    * @param gatewayMessage the gateway message
    * @return GatewayLogger
    */
    global GatewayLogger withGatewayMessage(String gatewayMessage) {
        if (gatewayMessage == null || !String.isNotBlank(gatewayMessage)) return this;
        log.put(fields.get(Field.GatewayMessage), StringX.clamp(gatewayMessage, 255));
        return this;
    }

    /**
    * includes the error message
    * @param errorMessage the error message
    * @return GatewayLogger
    */
    global GatewayLogger withErrorMessage(String errorMessage) {
        if (errorMessage == null || !String.isNotBlank(errorMessage)) return this;
        log.put(fields.get(Field.ErrorMessage), StringX.clamp(errorMessage, 131072, '...'));
        return this;
    }

    /**
    * includes the request
    * @param req the request
    * @param nothing the nothing
    * @return GatewayLogger
    */
    global virtual GatewayLogger withRequest(Map<String, Object> req, Integer nothing) {
        if (req == null) log.put(fields.get(Field.Request), StringX.clamp(JSON.serializePretty(req), 131072, '...'));
        return this;
    }

    /**
    * includes the request
    * @param req the request
    * @return GatewayLogger
    */
    global GatewayLogger withRequest(Map<String, Object> args) {
        if (args == null) return this;
        String body = JSON.serialize(args.get('body'))?.remove('\\n')?.remove('\\');
        if (this.level > 0)
            body = MapX.dump(new Map<String, String> {
                'Endpoint' => String.valueOf(args.get('endPoint')),
                'Content-Type' => String.valueOf(args.get('contentType')),
                'HTTP Method' => String.valueOf(args.get('method')),
                '' => body
            });
        log.put(fields.get(Field.Request), StringX.clamp(body, 131072, '...'));
        return this;
    }

    /**
    * includes the request
    * @param req the request
    * @return GatewayLogger
    */
    global GatewayLogger withRequest(HttpRequest req) {
        if (req == null) return this;
        log.put(fields.get(Field.Request), StringX.clamp(req.getBody(), 131072, '...'));
        return this;
    }

    /**
    * includes the request
    * @param req the request
    * @return GatewayLogger
    */
    global GatewayLogger withRequest(RestRequest req) {
        if (req == null) return this;
        String body = JSON.serialize(req.requestBody?.toString())?.remove('\\n')?.remove('\\');
        if (this.level > 0)
            body = MapX.dump(new Map<String, String> {
                'Request URI' => String.valueOf(req.requestURI),
                'Header' => MapX.dump('Header', req.headers),
                'HTTP Method' => req.httpMethod,
                'Remote Address' => req.remoteAddress,
                'Request Parameters' => MapX.dump('Params', req.params),
                '' => body
            });
        log.put(fields.get(Field.Request), StringX.clamp(body, 131072, '...'));
        return this;
    }

    /**
    * includes the response
    * @param res the response
    * @param statusCode the status code
    * @return GatewayLogger
    */
    global virtual GatewayLogger withResponse(Map<String, Object> res, Integer statusCode) {
        if (res != null) log.put(fields.get(Field.Response), StringX.clamp(JSON.serializePretty(res), 131072, '...'));
        log.put(fields.get(Field.ResultCode), statusCode);
        return this;
    }

    /**
    * includes the response
    * @param res the response
    * @return GatewayLogger
    */
    global GatewayLogger withResponse(HttpResponse res) {
        if (res == null) return this;
        String body = res.getBody();
        if (this.level > 0)
            body = MapX.dump(new Map<String, String> {
                'Headers' => String.join(res.getHeaderKeys(), ','),
                '' => body
            });
        log.put(fields.get(Field.Response), StringX.clamp(body, 131072, '...'));
        log.put(fields.get(Field.ResultCode), res.getStatusCode());
        return this;
    }
    
    /**
    * includes the response
    * @param res the response
    * @return GatewayLogger
    */
    global GatewayLogger withResponse(RestResponse res) {
        if (res == null) return this;
        String body = res.responseBody?.toString();
        if (level > 0)
            body = Mapx.dump(new Map<String, String> {
                'Headers' => String.valueOf(res.headers),
                '' => body
            });
        log.put(fields.get(Field.Response), StringX.clamp(body, 131072, '...'));
        log.put(fields.get(Field.ResultCode), res.statusCode);
        return this;
    }

    /**
    * return a string
    * @return String 
    */
    global override String toString() {
        return String.format('[Logger] {0}: {1}', new Object[] { log.get(fields.get(Field.InteractionType)), log });
    }
}
