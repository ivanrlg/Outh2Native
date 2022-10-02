codeunit 80103 GenericApiCalls
{
    procedure CreateRequest(RequestUrl: Text; AccessToken: Text): Text
    var
        TempBlob: Codeunit "Temp Blob";
        IsSuccessful: Boolean;
        HttpClient: HttpClient;
        MailContent: HttpContent;
        MailContentHeaders: HttpHeaders;
        RequestHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        ResponseStream: InStream;
        StatusCode: Integer;
        JObject: JsonObject;
        APICallResponseMessage: Text;
    begin
        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);
        RequestMessage.SetRequestUri(RequestUrl);
        RequestMessage.Method('GET');

        Clear(TempBlob);
        TempBlob.CreateInStream(ResponseStream);

        IsSuccessful := HttpClient.Send(RequestMessage, ResponseMessage);

        if not IsSuccessful then
            exit('An API call with the provided header has failed.');

        if not ResponseMessage.IsSuccessStatusCode() then begin
            StatusCode := ResponseMessage.HttpStatusCode();
            exit('The request has failed with status code ' + Format(StatusCode));
        end;

        if not ResponseMessage.Content().ReadAs(ResponseStream) then
            exit('The response message cannot be processed.');

        if not JObject.ReadFrom(ResponseStream) then
            exit('Cannot read JSON response.');

        JObject.WriteTo(APICallResponseMessage);
        APICallResponseMessage := APICallResponseMessage.Replace(',', '\');

        exit(APICallResponseMessage);
    end;

}