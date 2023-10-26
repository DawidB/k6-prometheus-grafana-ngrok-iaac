lineSeparator="----------------------------------------------------------"

updatePassword() {
    printf "\n$lineSeparator\n$1\n"
    read -s password

    encryptedPassword=$(bcrypt-cli "$password" 12)
    echo "Encrypted password: ${encryptedPassword:0:10}..."

    old_pattern="$2"
    new_text="$2$encryptedPassword"
    echo "Replace '$old_pattern' with '$new_text' in '$3'"
    sed -i "/^$old_pattern/c\\$new_text" "$3"
}

prometheus_web_config_file="../prometheus/web-config.yml"
grafana_data_source_file="../grafana/provisioning/datasources/datasource.yml"
grafana_config_file="../grafana/grafana.ini"
docker_compose_file="../docker-compose.yml"

#ngrok
printf "\n$lineSeparator\nPlease enter Ngrok auth token:\n"
read -s authToken
sed -i "/^      - NGROK_AUTHTOKEN=/c\\      - NGROK_AUTHTOKEN=$authToken" "$docker_compose_file"

printf "\n$lineSeparator\nPlease enter Ngrok domain address:\n"
read domainAddress
sed -i "/^      - \"--domain=/c\\      - \"--domain=$domainAddress\"" "$docker_compose_file"

#prometheus
updatePassword "Please enter Prometheus admin password:" "    admin: " "$prometheus_web_config_file"
sed -i "/^      - \"--basic-auth=admin:/c\\      - \"--basic-auth=admin:$password\"" "$docker_compose_file"

updatePassword "Please enter Prometheus remote writer's account password: " "    remote-writer: " "$prometheus_web_config_file"
sed -i "/^    basicAuthPassword:/c\\    basicAuthPassword: $password" "$grafana_data_source_file"
sed -i "/^      - \"--basic-auth=remote-writer:/c\\      - \"--basic-auth=remote-writer:$password\"" "$docker_compose_file"

#grafana
updatePassword "Please enter Grafana admin password:" "admin_password=" "$grafana_config_file"