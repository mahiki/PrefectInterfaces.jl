println("Active Prefect Environment: $(PREFECT_PROFILES["active"])")
try
    println("Calling $ACTIVE_API/health")
    response = HTTP.get("$ACTIVE_API/health")
    println("Server reponse status: $(response.status) ", response.status == 200 ? "OK" : "BAD")
catch ex
    @error "Prefect server must be available at active profile to run tests\n" *
        "PREFECT_API_URL: $ACTIVE_API \n" *
        "Prefect Server Not Healthy: $(ex.url) $(ex.error.ex.msg)\n" *
        "Exiting tests."
    exit(420)
end
