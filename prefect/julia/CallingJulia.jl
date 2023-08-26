# This module is a demo of executing a julia process from a Prefect flow.

module CallingJulia

function bytor_message(; input="Default message.", prefect_api_url="http://127.0.0.1:4300/api")
    println("Hello from the Julia script, prints are logged from prefect flow.")

    @info "By-Tor left a message"  input
    @info "You can using PrefectInterfaces commands to retrieve blocks because" prefect_api_url
end

export bytor_message

end # CallinJulia