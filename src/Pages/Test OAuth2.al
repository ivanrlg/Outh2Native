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

        OAuth2.AcquireAuthorizationCodeTokenFromCache(
            ClientId,
            ClientSecret,
            RedirectURL,
            OAuthAuthorityUrl,
            Scopes,
            AccessTokenForGraph);

        if AccessTokenForGraph = '' then
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

        SetResultStyle1();
    end;

    local procedure GetAccessTokenForBC()
    var
        PromptInteraction: Enum "Prompt Interaction";
        AuthCodeError: Text;
        Scopes: List of [Text];
    begin
        Scopes.Add(Constants.GetResourceURLForApiBC() + '.default');

        OAuth2.AcquireAuthorizationCodeTokenFromCache(
        ClientId,
        ClientSecret,
        RedirectURL,
        OAuthAuthorityUrl,
        Scopes,
        AccessTokenForBC);

        if AccessTokenForBC = '' then
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

        SetResultStyle2();
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
}