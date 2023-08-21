function server_connection_check()
    println("Active Prefect Environment: $(PREFECT_PROFILES["active"])")
    try
        response = HTTP.get("$ACTIVE_API/health")
        label = response.status == 200 ? "200 OK" : "$(response.status) BAD"
        @info "Prefect Server must be running, i.e. `prefect server start`\n" *
            "Calling $ACTIVE_API/health\n" * 
            "Server reponse status: $(label)"
        return true
    catch ex
        @warn "Prefect server must be available at active profile to run certain tests\n" *
            "PREFECT_API_URL: $ACTIVE_API \n" *
            "Prefect Server Not Healthy" typeof(ex) ex.url ex.error.ex.msg
        return false
    end
end
