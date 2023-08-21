Module CallinJulia

function bytor_message(input="Default message."; prefect_api_url="http://127.0.0.1:4300/api")
    println("Hello from the Julia script.")
    println("These will get logged from the prefect flow.")
    @info "By-Tor left a message" input
    @info "You can using PrefectInterfaces commands because you have" prefect_api_url
end

end # CallinJulia