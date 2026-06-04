FROM nginx:1.31.1

COPY ./templates /etc/nginx/templates

COPY ./transform_split_clients.sh /transform_split_clients.sh

# Make the script executable
RUN chmod +x /transform_split_clients.sh

# Set the entrypoint to run your script first
ENTRYPOINT ["/transform_split_clients.sh"]

CMD envsubst '$MONOLITH_URL $MONOLITH_DOMAIN $MONOLITH_PORT $MOVIES_SERVICE_URL $MOVIES_SERVICE_DOMAIN $MOVIES_SERVICE_PORT $EVENTS_SERVICE_URL $SPLIT_CLIENT_MOVIES_MIGRATION_PERCENT $MOVIES_MIGRATION_PERCENT $GRADUAL_MIGRATION' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'