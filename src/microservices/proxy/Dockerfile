FROM nginx:1.31.1

COPY ./templates /etc/nginx/templates

CMD envsubst '$MONOLITH_URL $MONOLITH_DOMAIN $MONOLITH_PORT $MOVIES_SERVICE_URL $MOVIES_SERVICE_DOMAIN $MOVIES_SERVICE_PORT $EVENTS_SERVICE_URL $MOVIES_MONOLITH_PERCENT $MOVIES_MIGRATION_PERCENT $GRADUAL_MIGRATION' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'