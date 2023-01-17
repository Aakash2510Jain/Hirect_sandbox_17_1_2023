public class JSON2Apex {

	public class Operators {
		public String label;
		public String value;
	}

	public Integer index;
	public String selectedField;
	public List<Operators> operators;
	public String selectedOpetor;
	public Boolean showInput;
	public String inputValue;
	public String selectFeildType;
	public String field;
	public String inputValues;

	
	public static List<JSON2Apex> parse(String json) {
		return (List<JSON2Apex>) System.JSON.deserialize(json, List<JSON2Apex>.class);
	}
}