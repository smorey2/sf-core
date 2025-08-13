/**
* http lambda
*/
global interface IHttpLambda {
	/**
	* then
	* @param task the task
	* @param batch the batch
	* @param response the response
	*/
	void then(HttpTask task, HttpBatch batch, Object response);
	/**
	* end
	* @param task the task
	* @param batch the batch
	* @param success the success
	*/
	void end(HttpTask task, HttpBatch batch, Boolean success);
}