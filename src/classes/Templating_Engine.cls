/*
	
*/
public class Templating_Engine 
{
	private static String regex = '\\{!([\\w\\.]+)\\}';

	private static Map<String, String> globalReplaceVals;
	private Map<String, Id> recordIdByNamespace;
	private Map<String, SObject> recordByNamespace;
	private String body;

	public Templating_Engine(String body)
	{
		this.body = body;
	}

	public String execute()
	{
		queryRecords();
		swapMergeFields();
	}

	public void addMergeRecord(Id recordId, String namespace)
	{
		if(null == recordIdByNamespace)
		{
			recordIdByNamespace = new Map<String, Id>();
		}
		recordIdByNamespace.put(namespace, recordId);
	}

	public void addGlobalVariable(String label, String value)
	{
		if(null == globalReplaceVals)
		{
			globalReplaceVals = new Map<String, String>();
		}
		globalReplaceVals.put(label, value);
	}

	private void swapMergeFields()
	{

	}

	private void queryRecords()
	{
		if(null == recordByNamespace)
		{
			recordByNamespace = new Map<String, SObject>();
		}

		for(String namespace : recordIdByNamespace.keySet())
		{
			Id recordId = recordIdByNamespace.get(namespace);
			Set<String> fields = getFields(this.body, recordId);
			doQuery(recordId, fields);
		}
	}

	private static SObject doQuery(Id recordId, Set<String> fields)
	{
		List<SObject> sobjs = doQuery(new Set<Id>{recordId}, fields);
		if(null == sobjs || sobjs.isEmpty())
		{
			throw new Templating_Exception('Record with Id: ' + recordId + ' not found');
		}
		return sobjs.get(0);
	}

	private static List<SObject> doQuery(Set<Id> recordIds, Set<String> fields)
	{
		String selectString = 'SELECT ';
		selectString += String.join(new List<String>(fields), ',');
		selectString += ' FROM ';
		selectString += getSObjectAPINameFromId(new List<Id>(recordIds)[0]);
		selectString += ' WHERE Id IN (\'';
		selectString += String.join(new List<Id>(recordIds), '\',\'');
		selectString += '\')';
		System.debug(LoggingLevel.INFO, selectString);
		return Database.Query(selectString);	
	}

	private Set<String> getFields(String body, Id recordId)
	{
		return null;
	}

	private static String getSObjectAPINameFromId(Id recordId)
	{
		return recordId.getSobjectType().getDescribe().getName();
	} 

	public class Templating_Exception extends Exception {}

}