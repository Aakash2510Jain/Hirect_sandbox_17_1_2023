public class UserInfo_client {
    
    public String EmailId;
    
    public static UserInfo_client parse(String json) {
        return (UserInfo_client) System.JSON.deserialize(json, UserInfo_client.class);
    }

}