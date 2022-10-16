page 80100 "Test OAuth2"
{
    ApplicationArea = All;
    Caption = 'Test OAuth2';
    UsageCategory = Administration;
    Editable = true;

    layout
    {
        area(Content)
        {
            group(Setup)
            {
                Caption = 'Setup';

                field(ClientId; ClientId)
                {
                    ApplicationArea = All;
                    Caption = 'Application ID';
                }
                field(ClientSecret; ClientSecret)
                {
                    ApplicationArea = All;
                    Caption = 'Client secret';
                    ExtendedDatatype = Masked;
                }
                field(RedirectURL; RedirectURL)
                {
                    ApplicationArea = All;
                    Caption = 'Redirect URI';
                }

                field(TenantId; AadTenantId)
                {
                    ApplicationArea = All;
                    Caption = 'Tenant ID';
                }
            }

            group(Results)
            {
                Caption = 'Token Response';
                Editable = false;

                group(APIGraphGroup)
                {
                    Caption = 'Api Graph';
                    field(AccessTokenForGraph; AccessTokenForGraph)
                    {
                        ApplicationArea = All;
                        Caption = 'Access Token';
                        trigger OnAssistEdit()
                        begin
                            if AccessTokenForGraph = '' then
                                exit;
                            Message(AccessTokenForGraph);
                        end;
                    }
                    field(Status1; Result1)
                    {
                        ApplicationArea = All;
                        Caption = 'Result Token';
                        StyleExpr = ResultStyleExpr1;
                    }
                }

                group(ApiBCGroup)
                {
                    Caption = 'Api BC';
                    field(AccessTokenForBC; AccessTokenForBC)
                    {
                        ApplicationArea = All;
                        Caption = 'Access Token';
                        trigger OnAssistEdit()
                        begin
                            if AccessTokenForBC = '' then
                                exit;
                            Message(AccessTokenForBC);
                        end;
                    }
                    field(Status2; Result2)
                    {
                        ApplicationArea = All;
                        Caption = 'Result Token';
                        StyleExpr = ResultStyleExpr2;
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(ApiGraph)
            {
                Caption = 'Api Graph';
                action(GetTokenForApiGraph)
                {
                    ApplicationArea = All;
                    PromotedCategory = Process;
                    Promoted = true;
                    Caption = 'Get Token for API Graph';
                    Image = ServiceSetup;

                    trigger OnAction()
                    begin
                        GetAccessTokenForGraph();
                    end;
                }
                action(CallApiGraph)
                {
                    ApplicationArea = All;
                    PromotedCategory = Process;
                    Promoted = true;
                    Caption = 'Call Api Graph';
                    Image = ChangeStatus;
                    trigger OnAction()
                    begin
                        GetAccessTokenForGraph();

                        if AccessTokenForGraph = '' then
                            Error('No Access Token has been acquired');

                        APICallResponse := GenericApiCalls.CreateRequest(ApiGraph, AccessTokenForGraph);

                        Message(APICallResponse);
                    end;
                }
            }

            group(ApiBC)
            {
                Caption = 'Api BC';
                action(GetTokenForApiBC)
                {
                    ApplicationArea = All;
                    PromotedCategory = Process;
                    Promoted = true;
                    Caption = 'Get Token for API BC';
                    Image = ServiceSetup;

                    trigger OnAction()
                    begin
                        GetAccessTokenForBC();
                    end;
                }
                action(CallApiListCompanies)
                {
                    ApplicationArea = All;
                    PromotedCategory = Process;
                    Promoted = true;
                    Caption = 'Call Api List Companies';
                    Image = ChangeStatus;
                    trigger OnAction()
                    begin
                        GetAccessTokenForBC();

                        if AccessTokenForBC = '' then
                            Error('No Access Token has been acquired');

                        APICallResponse := GenericApiCalls.CreateRequest(ApiListCompanies, AccessTokenForBC);

                        Message(APICallResponse);
                    end;
                }
            }
        }
    }

    local procedure GetAccessTokenForGraph()
    var
        PromptInteraction: Enum "Prompt Interaction";
        AuthCodeError: Text;
        Scopes: List of [Text];
    begin
        Scopes.Add(Constants.GetResourceURLForApiGraph() + '.default');

        //Gets the access token from cache or a refreshed token via OAuth2 v2.0 protocol.
        OAuth2.AcquireAuthorizationCodeTokenFromCache(
            ClientId,
            ClientSecret,
            RedirectURL,
            OAuthAuthorityUrl,
            Scopes,
            AccessTokenForGraph);

        if AccessTokenForGraph = '' then

            //Gets the authorization token based on the authorization code via the OAuth2 v2.0 code grant flow.
            OAuth2.AcquireTokenByAuthorizationCode(
                      ClientId,
                      ClientSecret,
                      OAuthAuthorityUrl,
                      RedirectURL,
                      Scopes,
                      PromptInteraction::Consent,
                      AccessTokenForGraph,
                      AuthCodeError);

        if AccessTokenForGraph = '' then
            DisplayErrorMessage1(AuthError)
        else
            Result1 := 'Success';

        //**************************  ISOLATE STORAGE ****************************//
        //Delete the old Token if it exists
        if IsolatedStorage.Contains('AccessTokenForGraph', DataScope::Module) then
            IsolatedStorage.Delete('AccessTokenForGraph', DataScope::Module);

        //Set new AccessTokenForGraph
        IsolatedStorage.Set('AccessTokenForGraph', AccessTokenForGraph, DataScope::Module);

        SetResultStyle1();
        //**************************  ISOLATE STORAGE ****************************//
    end;

    local procedure GetAccessTokenForBC()
    var
        PromptInteraction: Enum "Prompt Interaction";
        AuthCodeError: Text;
        Scopes: List of [Text];
    begin
        Scopes.Add(Constants.GetResourceURLForApiBC() + '.default');

        //Gets the access token from cache or a refreshed token via OAuth2 v2.0 protocol.
        OAuth2.AcquireAuthorizationCodeTokenFromCache(
        ClientId,
        ClientSecret,
        RedirectURL,
        OAuthAuthorityUrl,
        Scopes,
        AccessTokenForBC);

        if AccessTokenForBC = '' then

            //Gets the authorization token based on the authorization code via the OAuth2 v2.0 code grant flow.
            OAuth2.AcquireTokenByAuthorizationCode(
                      ClientId,
                      ClientSecret,
                      OAuthAuthorityUrl,
                      RedirectURL,
                      Scopes,
                      PromptInteraction::Consent,
                      AccessTokenForBC,
                      AuthCodeError);

        if AccessTokenForBC = '' then
            DisplayErrorMessage2(AuthError)
        else
            Result2 := 'Success';

        //**************************  ISOLATE STORAGE ****************************//
        //Delete the old Token if it exists
        if IsolatedStorage.Contains('AccessTokenForBC', DataScope::Module) then
            IsolatedStorage.Delete('AccessTokenForBC', DataScope::Module);

        //Set new AccessTokenForBC
        IsolatedStorage.Set('AccessTokenForBC', AccessTokenForBC, DataScope::Module);

        SetResultStyle2();
        //**************************  ISOLATE STORAGE ****************************//
    end;

    trigger OnOpenPage()
    begin
        ClientId := Constants.GetClientId();
        ClientSecret := Constants.GetClientSecret();
        RedirectURL := Constants.GetRedirectURL();
        AadTenantId := Constants.GetAadTenantId();
        ApiGraph := Constants.GetApiGraphMe();
        ApiListCompanies := Constants.GetApiListCompanies();
        OAuthAuthorityUrl := Constants.GetOAuthAuthorityUrl();

        //**************************  ISOLATE STORAGE ****************************//

        //We check if an AccessToken exists for AccessTokenForGraph
        if IsolatedStorage.Contains('AccessTokenForGraph', DataScope::Module) then begin

            //If it exists, we retrieve it with the 'Get method' and store it in the AccessTokenForGraph variable.
            IsolatedStorage.Get('AccessTokenForGraph', DataScope::Module, AccessTokenForGraph);
            Result1 := 'Success';
            SetResultStyle1();
        end;

        //We check if an AccessToken exists for AccessTokenForBC
        if IsolatedStorage.Contains('AccessTokenForBC', DataScope::Module) then begin

            //If it exists, we retrieve it with the 'Get method' and store it in the AccessTokenForBC variable.
            IsolatedStorage.Get('AccessTokenForBC', DataScope::Module, AccessTokenForBC);
            Result2 := 'Success';
            SetResultStyle2()
        end;

        //**************************  ISOLATE STORAGE ****************************//

    end;

    local procedure SetResultStyle1()
    begin
        if Result1 = 'Success' then
            ResultStyleExpr1 := 'Favorable';

        if Result1 = 'Error' then
            ResultStyleExpr1 := 'Unfavorable';
    end;

    local procedure SetResultStyle2()
    begin
        if Result2 = 'Success' then
            ResultStyleExpr2 := 'Favorable';

        if Result2 = 'Error' then
            ResultStyleExpr2 := 'Unfavorable';
    end;

    local procedure DisplayErrorMessage1(AuthError: Text)
    begin
        Result1 := 'Error';
        if AuthError = '' then
            ErrorMessage := 'Authorization has failed.'
        else
            ErrorMessage := StrSubstNo('Authorization has failed with the error: %1.', AuthError);
    end;

    local procedure DisplayErrorMessage2(AuthError: Text)
    begin
        Result2 := 'Error';
        if AuthError = '' then
            ErrorMessage := 'Authorization has failed.'
        else
            ErrorMessage := StrSubstNo('Authorization has failed with the error: %1.', AuthError);
    end;

    var
        GenericApiCalls: Codeunit GenericApiCalls;
        Constants: Codeunit Constants;
        OAuth2: Codeunit Oauth2;
        AadTenantId, APICallResponse, ClientId, ClientSecret : Text;
        AccessTokenForBC, AccessTokenForGraph, AuthError, ErrorMessage, OAuthAuthorityUrl, RedirectURL : text;
        ApiGraph, ApiListCompanies : Text;
        Result1, Result2, ResultStyleExpr1, ResultStyleExpr2 : text;
        EncryptionManagement: Codeunit "Cryptography Management";
}