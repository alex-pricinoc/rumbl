wolfram =  %{
  name: "Wolfram",
  username: "wolfram",
  email: "wolfram@example.com",
  password: "secretandlongpasswordok"
}

{:ok, _} = Rumbl.Accounts.register_user(wolfram)
