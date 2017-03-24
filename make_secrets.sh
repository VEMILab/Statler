#!/bin/bash

# From https://irb.rocks/create-secrets-yml-file-dynamically-with-bash/

if [ ! -f ./config/secrets.yml ]; then
  echo -e "Generating a secrets.yml file"

  # Random Keys
  KEY_DEV=$(bin/rake secret)
  KEY_TEST=$(bin/rake secret)

  # Generate the file
  cat > ./config/secrets.yml <<EOL
development:
  secret_key_base: ${KEY_DEV}
test:
  secret_key_base: ${KEY_TEST}
production:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
EOL
fi

echo "Secrets.yml generated."