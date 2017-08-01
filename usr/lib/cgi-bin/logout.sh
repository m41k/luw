#!/bin/bash
echo -e "Content-Type: text/html\n\n"
cat <<EOF
        <script>
         if (document.execCommand("ClearAuthenticationCache"))
         {
          document.location = "http://$SERVER_NAME:$SERVER_PORT";
         } else {
          document.location = "http://NewAcess:NewAcess@$SERVER_NAME:$SERVER_PORT"
         }
</script>
EOF
