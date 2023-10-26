prometheus_web_config_file="../prometheus/web-config.yml"
grafana_data_source_file="../grafana/provisioning/datasources/datasource.yml"
grafana_config_file="../grafana/grafana.ini"
docker_compose_file="../docker-compose.yml"

echo "Destroying secrets..."
sed -i "/^    admin:/c\\    admin: <encrypted-password-1>" "$prometheus_web_config_file"
sed -i "/^    remote-writer:/c\\    remote-writer: <encrypted-password-2>" "$prometheus_web_config_file"

sed -i "/^    basicAuthPassword:/c\\    basicAuthPassword: <plain-text-password>" "$grafana_data_source_file"
sed -i "/^admin_password=/c\\admin_password=<plain-text-password>" "$grafana_config_file"

sed -i "/^      - NGROK_AUTHTOKEN=/c\\      - NGROK_AUTHTOKEN=<auth-token>\"" "$docker_compose_file"
sed -i "/^      - \"--basic-auth=admin:/c\\      - \"--basic-auth=admin:<plain-text-password>\"" "$docker_compose_file"
sed -i "/^      - \"--basic-auth=remote-writer:/c\\      - \"--basic-auth=remote-writer:<plain-text-password-2>\"" "$docker_compose_file"
sed -i "/^      - \"--domain=/c\\      - \"--domain=<domain-address>\"" "$docker_compose_file"

echo "Done!"