codeunit 80102 MyIsolatedStorage
{
    procedure Store(MySecrect: Text)
    begin
        //Delete the old Secrect if it exists
        if IsolatedStorage.Contains('MySecrect', DataScope::Module) then
            IsolatedStorage.Delete('MySecrect', DataScope::Module);

        //Set new MySecrect
        IsolatedStorage.Set('MySecrect', MySecrect, DataScope::Module);
    end;

    procedure Read() MySecrect: Text
    begin
        //We check if an  Secrect exists for MySecrect
        if IsolatedStorage.Contains('MySecrect', DataScope::Module) then begin

            //If it exists, we retrieve it with the 'Get method' and store it in the MySecrect variable.
            IsolatedStorage.Get('MySecrect', DataScope::Module, MySecrect);

            exit(MySecrect);
        end;
    end;
}
